
+ ArrayedCollection {
	pseq {|repeats=inf, offset=0|
		^Pseq(this, repeats, offset);
	}

	pshuf {|repeats=inf|
		^Pshuf(this, repeats);
	}

	prand {|repeats=inf|
		^Prand(this, repeats);
	}
}

+ Pattern {
	plazy {
		^Plazy({this});
	}
	pfunc {
		^Pfunc({this});
	}

}

+ Function {
	plazy {
		^Plazy(this);
	}
	pfunc {
		^Pfunc({this});
	}

}


// pwhite, pbrown, doesn't make sense, doesn't save any typing


+ Pattern {
        iterN { |n| ^this.asStream.nextN(n) }
}