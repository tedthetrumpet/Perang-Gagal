/* _          _ _   _        _                            _
  | |_ ___ __| | |_| |_  ___| |_ _ _ _  _ _ __  _ __  ___| |_
  |  _/ -_) _` |  _| ' \/ -_)  _| '_| || | '  \| '_ \/ -_)  _|
   \__\___\__,_|\__|_||_\___|\__|_|  \_,_|_|_|_| .__/\___|\__|
@tedthetrumpet - Glasgow - Scotland          |_|              */
////////////////////////////////////////////////////////////////

//////////////////////// bag 01 'adrift & afloat'
P.all.do(_.clear);
t.tempo_(95/60);
s.latency_(0.05);

// kempul introduction to adrift & afloat
// buka (jangan lupa – ageng tiga kali!)
P(\intro, \i, \bf, \b, ~arum[33].repeat(7), \a, 0.6, \l, 1.1).play.quant_(1)

// execute big gong, also chooses next kempul
// variasi ageng, ganti kempul
(
(i: \bf, b: ~arum.at(39), strum: 0.02.rrand(0.05), o: ([4,5] + {0.07.rand}.dup(2)), a: 0.1.rrand(0.3) + 0.6).play;
~kempul = ~arum[33..36].choose;
)

(i: \bf, b: ~kempul, a: 0.5 + 0.1.rrand(0.5) ).play // execute kempul

// notasi
[7] <7> [7] <7> [7] <7> x
[7] <7> [9] <7> [7] <7> x
[7] <5> [5] <5> [5] <5> [7] <7> x
[11] <9> [11] <9> [11] <9> x
[7] <7> [7] <7> [7] <7> [7] <7> x
[5] <5> [5] <5> [5] <5> x
[9] <9> [9] <5> [7] <9> x
[11] <11> [11] <11> [11] <11> x
[9] <9> [9] <7> [11] <5> [5] <5> x

////////////////////////////////////// bag 02 'divi2ions'

P.all.do(_.clear); t.tempo_(120/60); s.latency_(0.2);

(
P(\ag, \i, \bf, \amp, 0.7, \b, ~arum.at(39), \dur, 2*4*4);
P(\pul, \i, \slice, \b, ~arum.at([33,34,35,36].scramble).pseq.stutter(8), \dur, 1, \l, 1.2, \timingOffset, -0.05, \a, 0.3);
)

(
P(\ag).play;
P(\tuk, \i, \bf, \b, ~arum[68], \a, 0.7).play;
P(\pul).play;
P(\count, \count, (1..32).pseq, \rest, \, \print, Pfunc({ |e| e.at(\count).postln})).play;
)

P(\sek, \i, \slice, \amp, 0.3, \l, 1.1)
P(\sek, \buf, Pindex(~arum, [25,18] + {Pbrown(1,7,1,16).iterN(16).pseq(4)}.plazy.repeat)) // gembyang
P(\sek, \dur, 1/2).quant_(1) // irama 1/2
P(\sek, \dur, 1/4) // irama 1
P(\sek, \o, 5)
P(\sek).play

// initial tempo is 120/60 = 2
// change down irama over 16 beats, execute just before beat 16
P(\tempo, \tempo, 120/60/ Array.interpolation(16,1,2).pseq(1), \rest, \).trace(\tempo).play(quant:4) // dur = 1/4, t = 1

// change up irama over 16 beats, execute just before beat 16
P(\tempo, \tempo, 120/60/ Array.interpolation(16,2,1).pseq(1) , \rest, \).trace(\tempo).play(quant:4) // dur = 1/2, t =2

// seseg once only
P(\tempo, \tempo, 120/60/ Array.interpolation(16,1,0.75).pseq(1) , \rest, \).trace(\tempo).play(quant:4)

( // ending execute exactly on 4 of last bar!
P(\sek, \rpt, 1.repeat(1), \l, 16);
P(\ag, \rpt, 1.repeat(1)).play;
P(\tuk, \rpt, 1.repeat(1)).play;
P(\pul, \i, \bf, \rpt, 1.repeat(1)).play;
)

// uji balungan saja
// P(\bal, \i, \slice, \a, 0.7, \l, 1.1, \buf, ~arum.at(18+[1,2,4,3,6,2,7,2, 3,5,6,1,2,7,5,4,3,2]).pseq, \dur, (2!14 ++ (1!4)).flat.pseq).play.stop

/////////////////////////////////////// bag 03 'obse66ive'

P.all.do(_.clear)
P.defaultQuant_(6)

t.tempo_(75*2/60)
(
P(\tuk, \i, \bf, \b, ~arum[68], \a, 0.95, \dur, 1).play;
P(\count, \count, (1..6).pseq, \rest, \, \print, Pfunc({ |e| e.at(\count).postln})).play;
)

P(\polos, \o, [4,5,6]); // jangan lupa!

P(\polos, \i, \slice, \a, 0.5, \dur, 1/2, \rest, [\,1,\,1,\,1,\,1,1,\,1,\].pseq, \l, (1.1!10 ++ 2.1 ++ 1.1).pseq, \buf, ~arum.at(18+([6,6,6,5,6,6,6,3,5,6,6,6]++[6,5,6,6,6,5,6,6,3,6,5,6])).pseq).play

P(\sangsih, \i, \slice, \a, 0.3, \dur, 1/2, \rest, [1,\,1,\,1,\,\,1,\,1,1,\].pseq, \l, 1.1, \buf, ~arum.at(18+([7,7,7,7,4,7,7,7,7,5,6,7]++[7,7,7,7,4,7,7,7,7,6,5,7,])).pseq).quant_([6,1]).play(quant: [6,1])

P(\polos, \a, 0.5);P(\sangsih, \a, 0.2);
P(\polos, \a, 0.5);P(\sangsih, \a, 0.0);
P(\polos, \a, 0.2);P(\sangsih, \a, 0.0); // slenthem
P(\polos, \a, 0.0);P(\sangsih, \a, 0.0);
P(\polos, \o, [4,5,6])
P(\polos, \o, 5)

P(\g, \i, \slice, \buf, ~arum.at(39), \dur, (1..7).pshuf, \a, 0.5, \o, 6).play
P(\g).stop

P(\p, \i, \slice, \buf, ~arum.at({(33..36).choose}!12).pseq, \dur, (1..9).pshuf/2, \a, 0.5, \o, 6).play
P(\p).stop

P(\bon, \i, \slice, \buf, Pindex(~arum, (40..60).scramble[0..11].pseq, inf), \dur, 1/2, \a, 0.4)
P(\bon, \o, 5)
P(\bon, \d, 1/2)
P(\bon).play
P(\bon).stop

P(\tuk).stop
P(\count).stop

P(\polos, \a, 0.0); P(\sangsih, \a, 0.0); P(\g).stop; P(\p).stop; P(\tuk).stop; P(\bon).stop;

// granular (srepeg kangsa)
(
~gran=Synth(\warp, [\amp, 0.0]); // silent
P(\gran, \type, \set, \id, ~gran.nodeID, \args, #[\buf, \rate, \freq, \amp, \out]);
)
(// fade in
{P(\gran, \buf, [~l2[0]], \rate, -0.05, \dur, 1/4, \amp,  0.2 * (0..100).pseq(1)/100).quant_(0).play; // fade in
	(1/4*100).wait; "in".postln; P(\gran, \amp, 0.2)}.fork
)

P(\gran, \amp, 0.2)
P(\gran, \amp,  0.2 * (0..100).reverse.pseq(1)/100, \dur, 1/2).quant_(0); // fade out

(// gong
(i: \bf, b: ~arum.at(39), strum: 0.02.rrand(0.05), o: ([4,5] + {0.07.rand}.dup(2)), a: 0.1.rrand(0.3) + 0.7).play;
)

P.all.do(_.clear);
~gran.free;

// vim: syntax=supercollider
