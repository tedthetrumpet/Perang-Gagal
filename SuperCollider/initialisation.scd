(/*
gran, verb, echo and mate are now snips: cmd-period is now safe!

>>> pattern methods .pseq, .pshuf, .prand, .plazy

>>> Synths
SynthDescLib.global.at(\ssaw)

\slice
\dice
\warp
\bf
\bform
\blip
\rh2
\pad01

\vsaw
\morphbass
\nqbass
\ssaw

>>> functions: ~loadallbufs, ~listloops, ~rrest, ~rdur, ~logo, ~snip

>>> buffer folders: ~folder

>>> Loops
~listloops
~l is stereo
~l2 is paired mono for granulation

*/

//setup
Pdef.clear; Pdefn.clear; Ndef.clear;
// quantize changes to even four beat bars
Pbindef.defaultQuant_(4); Pdefn.defaultQuant_(4);
s.waitForBoot{
	var path, files, samplefolders, filesToLoad;
	filesToLoad = #["lcode09synths02.scd"]; // load synths and fx from separate file
	filesToLoad.do {|x| x.loadRelative};
	s.sync;

	Buffer.freeAll;
	// load one default buffer into 0 first
	s.sync;
	Buffer.read(s, "../bfsamples/".resolveRelative ++ "hitz02/00 DR npK_base no5_E-2.aif");
	s.sync;

	// load loops
	path = "../sldiwaloops/".resolveRelative;
	files = (path ++ "*.aiff").pathMatch ++ (path ++ "*.aif").pathMatch ++ (path ++ "*.wav").pathMatch;
	files = files.sort({ |a, b| a.basename < b.basename });
	~l = files.collect({ |i|  Buffer.read(s, i)});
	s.sync;
	~l2 = files.collect({ |i| 2.collect( {|c| Buffer.readChannel(s, i, channels: [c])}) });
	s.sync;
	// the -1 here is a hack, maybe because buff 0 has that default in it?
	~listloops = {
		([~l.collect(_.bufnum) - 1]++[~l.collect(_.path).collect(_.basename)]).flop.do(_.postln);
		nil
	};

	s.sync;

	// load samples
	~folders = PathName.new("../bfsamples/".resolveRelative).folders.collect(_.folderName);
	s.sync;
	~loadbufs = {
		|x="hitz02"| // default
		var buffers, monobufs, monotostereobufs, path, files;
		{
			path = "../bfsamples/".resolveRelative ++ x ++ "/";
			files = (path ++ "*.aiff").pathMatch ++ (path ++ "*.aif").pathMatch ++ (path ++ "*.wav").pathMatch;
			// read all in
			buffers = files.collect({ |i|  Buffer.read(s, i)});
			s.sync;
			// buffers[0].postln;
			// select mono bufs, read in again with duplicated channels
			monobufs = buffers.select({|i| i.numChannels==1});
			monotostereobufs = monobufs.collect(_.path).collect({ |i| Buffer.readChannel(s, i, channels:[0,0]) });
			s.sync;
			// free unneeded mono buffers
			monobufs.do({ |i| i.free});
			s.sync;
			// select stereo bufs and add in converted bufs
			buffers = buffers.select({|i| i.numChannels==2}) ++ monotostereobufs;
			// sort by name
			buffers = buffers.sort({ |a, b| a.path.basename < b.path.basename });
			currentEnvironment.put(x.asSymbol, buffers);
			("loaded " ++ x).postln
		}.fork;
	};
	s.sync;
	// not freeing all buffers here, would ruin the loops!
	~loadallbufs={ {~folders.do({ |x| ~loadbufs.(x); 1.wait }) }.fork};
	s.sync;
	// actually load samples
	~loadallbufs.value;
	/*	// granular setup, now moving entirely to snip
	~gran=Synth(\warp, [\buf, [~l2[0]], \rate, -0.05, \amp, 0.0]); // silent
	s.sync;
	// silent
	Pbindef(\gran, \type, \set, \id, ~gran.nodeID, \args, #[\buf, \rate, \freq, \amp, \out], \amp, 0.0).quant_(0).play;*/
	s.sync;

};



// rhythm function for isRest, ~rrest.() defaults to 8, or use ~rrest.(16), ~rrest.(7) etc
// creates syncopated rhythms by concatenating two and three beat cells, always with a downbeat
// rewritten for SC 3.9 because of changes to Rest
~rrest = { |a=8|
	var rhythm;
	a=(a-1).mod(16);
	rhythm = if ( a>7,
		{({[[1,0,0], [1,0,1]].choose}!4 ++ [[1,0].dup.flatten]).scramble.flatten.replace(0,\)
		},
		{({[[1,0,0], [1,0,1]].choose}!2 ++ [[1,0]]).scramble.flatten.replace(0,\)
		}
	);
	rhythm=rhythm[0..a];
};

// rhythm function for dur, ~rdur.() defaults to 8, or use ~r.(16), ~r.(7) etc
// uses the same function as above to work with durations instead of isRest

~rdur = { |b=8|
	var x;
	x = ~rrest.(b);
	// fortunately, this just ignores the \r symbols :)
	x = x.indicesOfEqual(1).replace(0, x.size).rotate(-1).differentiate;
};


t=TempoClock.default.tempo_(140/60);

// a collection of jazz chords in dorian mode, make some sort of sense if played in order
~jz=[
	[0,4,6,9],  [0,4,5,9],  [0,3,6,9],  [0,3,4,8],  [-1,3,4,8],  [-1,2,4,8],  [-1,2,5,8],  [-1,2,5,7],  [-1,2,4,7],  [-2,2,4,7],  [-2,1,4,7],  [-3,0,3,6],  [-3,1,2,6],  [-3,1,3,6],  [-3,2,3,6],  [-2,2,3,6],  [-1,2,3,7],  [0,2,4,8],  [0,3,5,8],  [2,4,6,8],  [3,4,6,9],  [3,5,7,10]
];


~snip = { |x|
	var names = PathName.new("../snippets/".resolveRelative).entries.collect(_.fileNameWithoutExtension);
	if (x==nil,
		{names.do(_.postln);
			"".post;
		},
		{ if (names.find([x]) != nil,
			{var filecontents = File.readAllString("../snippets/".resolveRelative ++ x ++ ".scd");
				Document.current.string_("\r\r" ++ filecontents ++ "\r", Document.current.selectionStart, 0)},
			{"that's not a snippet".error});

	});
};

Safety.addSynthDefFunc(\safeSoftHPF, { |numChans|
    { |limit=1, freq=50|
        // read the hardware output channel busses:
        var mainOuts = In.ar(0, numChans);
        // filter them for bad values
        var safeOuts = ReplaceBadValues.ar(mainOuts);
        // apply whatever custom limiting method
		// var limited = HPF.ar(HPF.ar(safeOuts, freq),freq).tanh * limit;
		var limited = HPF.ar(HPF.ar(safeOuts, freq),freq).softclip * limit;
		// var limited = BHiPass4.ar(safeOuts, freq).tanh * limit; // colours
        // write the safe and limited back to the output channels busses:
        ReplaceOut.ar(0, limited);
    }
});

Safety(s).defName_(\safeSoftHPF);


nil;
)
