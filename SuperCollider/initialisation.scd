// Quark dependencies!
// Quarks.install("miSCellaneous_lib") // version 0.23.0
// Quarks.install("SafetyNet")

// initialise buffers and read synths
(/*

>>> Synths

\slice
\warp
\bf

>>> Loops (only using one)
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
	filesToLoad = #["synths.scd"]; // load synths from separate file
	filesToLoad.do {|x| x.loadRelative};
	s.sync;

	Buffer.freeAll;
	// load one default buffer into 0 first
	s.sync;
	Buffer.read(s, "arum/".resolveRelative ++ "001 fa-dun.aiff");
	s.sync;

	// load loops
	path = "loops/".resolveRelative;
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

	// load multiple sample folders, but don't need as only loading 'arum'
	// ~folders = PathName.new("../bfsamples/".resolveRelative).folders.collect(_.folderName);
	s.sync;
	~loadbufs = {
		|x="arum"| // default
		var buffers, monobufs, monotostereobufs, path, files;
		{
			path = "arum/".resolveRelative;
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
	// don't need this code, only loading one folder
	// not freeing all buffers here, would ruin the loops!
	// ~loadallbufs={ {~folders.do({ |x| ~loadbufs.(x); 1.wait }) }.fork};
	// s.sync;
	// actually load samples
	~loadbufs.value;
	s.sync;

};

t=TempoClock.default.tempo_(140/60);

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
