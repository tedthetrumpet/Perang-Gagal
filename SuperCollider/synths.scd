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

SynthDef(\bf, {|out = 0 buf = 0 amp = 0.1 freq = (60.midicps) pan = 0.0 rev = 0 loop = 0 |
	var sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * (freq/60.midicps) * ((rev * -2) + 1), startPos: rev *  (BufFrames.kr(buf)-2), doneAction:2, loop:loop);
	sig = Balance2.ar(sig[0],sig[1], pan);
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




