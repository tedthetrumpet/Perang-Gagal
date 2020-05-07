SynthDef(\slice, { |out, gate=1, buf, slices=16, slice=0, freq = (60.midicps), amp=0.1, pan=0.0, loop=0, rev=0, attack=0.01, release 0.1 |
	var myenv, env, start, len, basefreq = 60.midicps, rate, sig;
	rate = freq / basefreq;
	len = BufFrames.kr(buf);
	start = (len / slices * slice);
	myenv = Env.asr(attackTime: attack, sustainLevel: 1, releaseTime: release);
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate * ((rev * -2) + 1), startPos: start, loop:loop);
	sig = Balance2.ar(sig[0],sig[1], pan);
	env = EnvGen.kr(myenv, gate, doneAction: 2);
	Out.ar(out, sig * env * amp)
}).add;

SynthDef(\dice, {|out=0, buf=0, amp=0.1, freq = (60.midicps), sustain=0.8, attack=0.001, slices=16, slice=0, pan=0.0, rev=0|
	var theEnv, rate, env, pitchEnv, sig, len, start;
	rate = freq/60.midicps;
	len = BufFrames.kr(buf);
	start = (len / slices * slice);
	theEnv = Env.perc(attackTime: attack, releaseTime: sustain/rate, curve: \cub);
	env = EnvGen.kr(theEnv, 1, doneAction: 2);
	sig = PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate * ((rev * -2) + 1), startPos: start);
	sig = Balance2.ar(sig[0],sig[1], pan);
	sig = sig * env;
	Out.ar(out, sig * amp)
}).add;

(
SynthDef(\warp, {|buf = #[0,0], rate = 1, freq = (60.midicps), amp= 0.1, out=0|
	var pointer, sig, fscale;
	fscale = freq/60.midicps;
	pointer = Phasor.ar(0, SampleDur.ir/BufDur.kr(buf) * rate);
	sig = Warp1.ar(1, buf, pointer, freqScale:fscale, windowSize:0.3, envbufnum:-1, overlaps:16, windowRandRatio:0.1, interp:4);
	Out.ar(out, sig * amp);
}).add;
);

// SynthDef(\bf, {|out = 0 buf = 0 amp = 0.1 freq = (60.midicps), pan = 0.0|
// 	var sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * freq/60.midicps, doneAction:2);
// 	sig = Balance2.ar(sig[0],sig[1], pan);
// 	Out.ar(out, sig * amp)
// }).add;


SynthDef(\bf, {|out = 0 buf = 0 amp = 0.1 freq = (60.midicps) pan = 0.0 rev = 0 loop = 0 |
	var sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * (freq/60.midicps) * ((rev * -2) + 1), startPos: rev *  (BufFrames.kr(buf)-2), doneAction:2, loop:loop);
	sig = Balance2.ar(sig[0],sig[1], pan);
	Out.ar(out, sig * amp)
}).add;


SynthDef(\bform, { |out = 0, freq = (60.midicps), form = 70, bw = 200, gate = 1, amp = 0.1, release = 0.5|
	// var env = EnvGen.kr(Env.adsr(), gate, doneAction:2);
	var env = EnvGen.kr(Env.adsr(releaseTime:release, decayTime:0.1), gate, doneAction:2);
	var sig = Formant.ar(freq * ((-1..1)/500 + 1), form * env.range(0.01,2), bw);
	sig = LeakDC.ar(sig);
	sig = sig * env;
	Out.ar(out, Splay.ar(sig) * amp)
}).add;

SynthDef(\rh1,{|out=0 freq = (60.midicps) amp=0.1 gate=1 cutoff=1500 rq=0.5 pan=0.0|
	var sig, filter, env, pulse1, pulse2, pulse3;
	pulse1 = Pulse.ar(freq:freq*1.01, width:0.2, mul:0.7);
	pulse2 = Mix(Pulse.ar(freq:freq*[1,33.5.midiratio], width:[0.2,0.1], mul:[0.7,0.5]));
	pulse3 = Pulse.ar(freq:freq*0.99, width:0.2, mul:0.7);
	sig = [pulse1, pulse2, pulse3];
	sig = Splay.ar(sig, spread: 0.9, center:pan);
	env = EnvGen.ar(Env.adsr(0.0,0.8,0.8,0.5),gate,doneAction:2);
	sig = BLowPass4.ar(sig,(cutoff*(env.squared))+200+freq,rq);
	sig = Compander.ar(3*sig,sig,0.5,1,4);
	Out.ar(out, sig * env * amp * 0.4);
}).add;

SynthDef(\rh2, {
	|
	// standard meanings
	out = 0, freq = 440, gate = 1, pan = 0, amp = 0.1,
	// all of these range from 0 to 1
	vel = 0.8, modIndex = 0.3, mix = 0.2, lfoSpeed = 0.08, lfoDepth = 0.1
	|
	var env1, env2, env3, env4;
	var osc1, osc2, osc3, osc4, snd;
	lfoSpeed = lfoSpeed * 12;
	freq = freq * 2;
	env1 = EnvGen.ar(Env.adsr(0.001, 1.25, 0.5, 0.04, curve: \lin));
	env2 = EnvGen.ar(Env.adsr(0.001, 1.00, 0.5, 0.04, curve: \lin));
	env3 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.5, 0.04, curve: \lin), gate, doneAction: 2);
	env4 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.5, 0.04, curve: \lin));
	osc4 = SinOsc.ar(freq * 0.5) * 2pi * 2 * 0.535887 * modIndex * env4 * vel;
	osc3 = SinOsc.ar(freq, osc4) * env3 * vel;
	osc2 = SinOsc.ar(freq * 15) * 2pi * 0.108819 * env2 * vel;
	osc1 = SinOsc.ar(freq, osc2) * env1 * vel;
	snd = Mix((osc3 * (1 - mix)) + (osc1 * mix));
	snd = snd * (SinOsc.ar(lfoSpeed) * lfoDepth + 1);
	snd = Pan2.ar(snd, pan, amp);
	Out.ar(out, snd);
}).add;

SynthDef(\blip, { |out= 0, freq = (60.midicps), nharm = 10, gate = 1, amp = 0.1, pan = 0.0|
	var sig = Blip.ar(freq * ((-2..2)/500 + 1), nharm); // five channels, detuned
	var env = EnvGen.kr(Env.adsr(), gate, doneAction:2);
	sig = sig * env;
	Out.ar(out, Splay.ar(sig, center:pan) * amp)
}).add;

SynthDef(\pad01, { |out = 0, freq = 440, cutoff = 500, amp = 0.2, gate=1, pan=0, attack=0.5|
	var snd;
	snd = Saw.ar([freq, freq+1, freq-1])*0.2;
	snd = snd + VarSaw.ar(0.99 * [freq, freq+1, freq-1], 0, LFTri.kr(0.03).range(0.25,0.9))*0.2;
	snd = Splay.ar(snd, center: pan);
	snd = RLPF.ar(snd, cutoff, 0.2);
	snd = snd * EnvGen.kr(Env.asr(attackTime: attack, releaseTime: 1, curve: -2), doneAction:2, gate: gate);
	// snd = NHHall.ar(snd, rt60: 1) * 4; // not a good idea!
	snd = snd * 2;
	Out.ar(out, snd * amp);
}).add;

// this now with added sin fundamental, subtle

SynthDef(\vsaw, { |out= 0, gate = 1, amp = 0.1, pan = 0.0|
	var sig = (VarSaw.ar(\freq.kr(60.midicps) + [0,1,2,3], width: \width.kr(0.5)));
	var fund = SinOsc.ar(\freq.kr) / 5;
	var env = EnvGen.kr(Env.adsr(), gate, doneAction:2);
	sig = (sig + fund) * env;
	Out.ar(out, Splay.ar(sig, center:pan) * amp)
}).add;

SynthDef("morphbass", { arg out, freq = (60.midicps), amp = 0.1, gate = 1;
	var snd, env, fenv, oscfreq;
	oscfreq = {freq * LFNoise2.kr(0.5).range(0.98, 1.02)}!3;
	snd = Splay.ar(LFSaw.ar(oscfreq, mul: amp));
	fenv = Env.adsr(0.7, 4, 0, 0.1).kr(gate: gate);
	env = Env.asr().kr(doneAction:2, gate: gate);
	snd = BMoog.ar(snd, ((fenv*freq) + 2*freq).clip(16000));
	snd = HPF.ar(snd, freq: 70);
	Out.ar(out, snd * env * amp);
}).add;


SynthDef(\nqbass, { | out, freq = (60.midicps), gate = 1, amp = 0.1, pan = 0 |
	var subfreq = freq / 2;
	var subenv = EnvGen.kr(Env.perc(0, 1));
	var env = EnvGen.kr(Env.adsr(0, 0.5, 0.2, 0.5), gate: gate, doneAction:2);
	var pluck = Pluck.ar(PinkNoise.ar, 1, 0.2, subfreq.reciprocal) * subenv * 2;
	var tri = VarSaw.ar(freq) * env;
	var sin = SinOsc.ar(freq) * env;
	var sub = (SinOsc.ar([subfreq, subfreq - 2, subfreq + 2]).sum * subenv).tanh;
	var click = RLPF.ar(Impulse.ar(0), [2000, 8000], 1).sum * 10;
	var sig = pluck + tri + sub + click;
	sig = BPeakEQ.ar(sig, 400, 0.5, -9);
	sig = sig.tanh;
	sig = (sig / 2.3).tanh;
	sig = MoogFF.ar(sig, XLine.ar(freq*150, freq*30, 0.1), 0.1);
	Out.ar(out, Pan2.ar(sig, pan) * amp * 7);
}).add;


SynthDef(\ssaw, {
	|
	out=0, freq=(60.midicps), pan=0.0, amp=0.1,
	sub=0.3, subwidth=0.5,
	sync=22.0, // this is a sync ratio going from 0.0 (no effect) to 60 semitones (5 octave above)
	voices = 7,
	det=0.0,
	cf = 1000,
	rq = 0.1
	|
	var env, sig, spread;
	env = EnvGen.ar(Env.perc(0.05, 0.2), 1, doneAction:2);
	voices = voices.clip(1, 16);

	sig = Array.fill(16, {
		|index|
		var onoff = (voices.round(1) > index);  // the ">" here will return 1 or 0 depending on voices
		onoff * SyncSaw.ar(freq *Rand(1.0, det.midiratio), freq*(sync.midiratio));
	});
	sig = sig + Pulse.ar(freq*0.5, subwidth, mul:sub);
	spread = (voices-1)/15;

	sig = sig * env * voices.linexp(1, 16, 1.0, 0.3) * (amp*2);

	sig = RLPF.ar(sig, cf, rq);

	sig = LeakDC.ar( sig.clip() );
	Out.ar(out, Splay.ar(sig, spread));
}).add;




///////////// fx

SynthDef(\echo, { |out = 0, in = 0, max = 1.0, delay = 0.5, decay = 3, amp = 0.5, bypass = 0|
	var sig, insig;
	insig = In.ar(in, 2);
	sig = CombL.ar(insig, max, delay, decay, amp, add: insig) * EnvGate();
	Out.ar(out, bypass * insig + ((1 - bypass) * sig));
}).add;

SynthDef(\mate, { |out=0, in=0, rate=1700, bits=7, amp=0.8|
	var sig = In.ar(in, 2);
	sig = Decimator.ar(sig, rate, bits);
	sig = LeakDC.ar(sig);
	Out.ar(out, sig * amp)
}).add;
