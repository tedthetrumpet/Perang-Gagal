"../bfsamples/".resolveRelative ++ "hitz02/00 DR npK_base no5_E-2.aif"

~here = "arum/".resolveRelative ++ "001 fa-dun.aiff"

~here = "Users/jsimon/Dropbox/github_repositories/Perang-Gagal/SuperCollider/arum/001 fa-dun.aiff"

File.exists(~here)


Buffer.read(s, "arum/".resolveRelative ++ "001 fa-dun.aiff");

(
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

)

~loadbufs.("arum")

~arum[0].play