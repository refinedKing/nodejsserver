var Q = {
	a:[],
	q:function(d) {
		if(! /function|number/.test(typeof (d))) return;

		Q.a.push(d);

		return Q;
	},
	d:function() {
		var s = Q.a.shift();
		if(!s) return;

		if(typeof (s) === "function") {
			s(),
			Q.d();
			return;
		}

		setTimeout(function(){
			Q.d();
		}, s);
	}
};
