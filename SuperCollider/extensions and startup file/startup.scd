{
	Server.program = Server.program + "-B 127.0.0.1"; // https://scsynth.org/t/security-advisory-scsynth-and-supernova-listen-on-all-network-interfaces-by-default/1176/1
	s.options.memSize = 65536 * 4;
	s.options.numBuffers = 1024 *4;

	EventShortcuts.addOnBase(\default, \js, (b: \buf));
	EventShortcuts.makeCurrent(\js);
	EventShortcuts.on;
	EventShortcuts.post(\js);

}.fork
