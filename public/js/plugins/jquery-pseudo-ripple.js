(function (factory) {
	if (typeof define === 'function' && define.amd) {
		// AMD. Register as an anonymous module.
		define(['jquery'], factory);
	} else if (typeof exports === 'object') {
		// Node/CommonJS style for Browserify
		module.exports = factory;
	} else {
		// Browser globals
		factory(jQuery);
	}
}(
/**
 * @param {jQuery} $
 */
function($) {
	let globDur = 400;
	let globEse = 'cubic-bezier(.4,0,.2,1)';
	let stylFix = $(document.createElement('style')).appendTo(document.head).addClass('ripple-custom-config')
	let stylSet = $(document.createElement('style')).appendTo(document.head).addClass('ripple-coordinates')
	let stylObj = {};
	let stylPos = {};
	let nowRuns = 0;
	let pointerdown = ('ontouchstart' in document.body) ? 'mousedown touchstart' : 'mousedown'
	$.fn.ripple = function(opt) {
		// console.log('RIPPLE :: ', this);
		let def = {
			ease: globEse,
			duration: globDur,
			onclick: false,
			disable: false,
			type: 'pointed', // 'centered' | 'icon' | 'trigger' | 'target'
			size: 1,
		};
		let selectorIDX = 'ripple-'+Math.round(Math.random()*1E9);
		// element setup
		$(this).each((i,v) => {
			let $elm = $(v);
			// jQuery('v').prop()
			if(typeof opt === 'string') {
				switch(opt) {
					case 'onmousedown':
						$elm[0].rippleVars.ondown = true;
						$elm
							.unbind('click', $elm[0].rippleVars.callback)
							.bind(pointerdown, $elm[0].rippleVars.callback);
						break;
					case 'onclick':
						$elm[0].rippleVars.ondown = false;
						$elm
							.unbind(pointerdown, $elm[0].rippleVars.callback)
							.bind('click', $elm[0].rippleVars.callback);
						break;
					case 'enable':
						$elm
							.removeClass('ripple-disabled')
							.bind($elm[0].rippleVars.ondown ? pointerdown : 'click', $elm[0].rippleVars.callback);
						break;
					case 'disable':
						$elm
							.addClass('ripple-disabled')
							// .removeClass('ripple')
							.unbind('click', $elm[0].rippleVars.callback)
							.unbind(pointerdown, $elm[0].rippleVars.callback);
						break;
					case 'ripple':
						$elm
							.removeClass('ripple-disabled')
							.trigger($elm[0].rippleVars.ondown ? 'mousedown' : 'click');
						break;
					case 'dismiss':
						$elm
							.removeClass('ripple')
						break;
					default:
						// $elm.bind('click', $elm[0].rippleVars.callback);
						break;
				}
				return;
			}
			def = $.extend(def, opt);
			def.duration = (typeof def.duration == 'number' ? def.duration : ((/^([2-9]|10)x$/i).test(def.duration) ? def.duration.toLowerCase() : globDur))
			let rePos = e => {
				// console.log(e);
				// let rid = 'ripple-running-'+Math.round(Math.random()*1E9);
				// debugger
				let rc, x1, y1, px, py;
				if(e.type == 'touchstart') {
					rc = e.currentTarget.getBoundingClientRect()
					x1 = e.originalEvent.touches[0].clientX - rc.left
					y1 = e.originalEvent.touches[0].clientY - rc.top
					px = e.originalEvent.touches[0].pageX
					py = e.originalEvent.touches[0].pageY
				} else {
					x1 = e.offsetX
					y1 = e.offsetY
					px = e.pageX
					py = e.pageY
				}
				if((x1 == 0 && y1 == 0) || ($elm[0].rippleVars.type == 'trigger')) stylPos[$elm[0].rippleVars.rid] = ``; // && e.pageX == 0 && e.pageY == 0 && e.clientX == 0 && e.clientY == 0
				else {
					let off = $elm.offset()
					stylPos[$elm[0].rippleVars.rid] = `
					.ripple-element.${ $elm[0].rippleVars.rid }.ripple::after {
						left: ${ 100*((px-off.left)/$elm.outerWidth())-100 }%;
						top: ${ 100*((py-off.top)/$elm.outerHeight()) }%;
					}`;
				}
				let stylTxt = '';
				for(let s in stylPos) {
					stylTxt += stylPos[s];
				}
				stylSet.html(stylTxt);
			};
			$elm[0].rippleVars = {
				idx: selectorIDX,
				rid: 'ripple-running-'+Math.round(Math.random()*1E9),
				size: parseInt(Math.min(Math.max(def.size, 1), 10)),
				ease: def.ease,
				type: def.type,
				time: ((/^([2-9]|10)x$/i).test(def.duration) ? parseInt(def.duration)*globDur : def.duration),
				timeout: 0,
				ondown: !def.onclick,
				callback: (e) => {
					// console.log(e.offsetX, e.offsetY, $elm.outerWidth(), $elm.outerHeight());
					if(e.type == 'mousedown' && 'ontouchstart' in document.body) return;
					if($elm.hasClass('ripple-disabled')) {
						return;
					}
					if($elm[0].rippleVars.timeout == 0) { // means NOT running
						nowRuns++;
						if($elm[0].rippleVars.type == 'pointed') rePos(e);
						$elm.addClass('ripple');
						/*
						$elm[0].rippleVars.timeout = 1;
						$elm.one('animationend', e => {
							// console.log('ripple END!!!');
							$elm.removeClass('ripple');
							$elm[0].rippleVars.timeout = 0;
							nowRuns--;
							if(nowRuns <= 0) {
								nowRuns = 0;
								stylPos = {};
								stylSet.html('');
							}
						})
						//*/
					} else { // running
						/*clearTimeout(_it.rippleVars.timeout);*/
						$elm.removeClass('ripple');
						if($elm[0].rippleVars.type == 'pointed') rePos(e);
						requestAnimationFrame(()=>{
							$elm.addClass('ripple');
						})
						/*$elm[0].rippleVars.timeout = setTimeout(()=>{
							// console.log('ripple OUT!!! 2');
							$elm.removeClass('ripple');
							clearTimeout($elm[0].rippleVars.timeout);
							$elm[0].rippleVars.timeout = 0;
						},$elm[0].rippleVars.time)*/
					}
					// cut from if block above
					clearTimeout($elm[0].rippleVars.timeout);
					$elm[0].rippleVars.timeout = setTimeout(()=>{
						// console.log('ripple OUT!!!');
						$elm.removeClass('ripple');
						$elm[0].rippleVars.timeout = 0;
						nowRuns--;
						if(nowRuns <= 0) {
							nowRuns = 0;
							stylPos = {};
							stylSet.html('');
						}
					}, $elm[0].rippleVars.time+16)
				}
			};
			let iconClass = '';
			switch($elm[0].rippleVars.type) {
				case 'icon':
					iconClass = ' ripple-icon'
					break;
				case 'icon-big':
					iconClass = ' ripple-icon-big'
					break;
				case 'icon-small':
					iconClass = ' ripple-icon-small'
					break;
				default:
					break;
			}
			$elm
				// .addClass('ripple-element'+iconClass+(def.disable ? ' ripple-disabled' : '')+' '+$elm[0].rippleVars.idx)
				.addClass('ripple-'+(def.type == 'trigger' ? 'trigger' : 'element')+iconClass+(def.disable ? ' ripple-disabled' : '')+' '+$elm[0].rippleVars.idx)
				.addClass($elm[0].rippleVars.rid)
				.addClass($elm[0].rippleVars.size >= 2 && $elm[0].rippleVars.size <= 10 ? 'ripple-anim-'+$elm[0].rippleVars.size+'x' : '')
				.addClass((/^([2-9]|10)x$/i).test(def.duration) ? 'ripple-time-'+parseInt(def.duration)+'x' : '')
				.bind($elm[0].rippleVars.ondown ? pointerdown : 'click', $elm[0].rippleVars.callback)
				.click(function cl(e) {
					if($elm[0].rippleVars.timeout == 0 && $elm[0].rippleVars.ondown && e.offsetY == 0 && e.offsetX == 0) $elm.trigger('mousedown', e);
				})
		}); // each
		if(typeof opt === 'object') {
			def = $.extend(def, opt);
			// if(def.duration !== globDur || def.ease !== globEse || def.size !== 1) stylObj[selectorIDX] = 
			if((def.duration !== globDur && (/^([2-9]|10)x$/i).test(def.duration) === false) || def.ease !== globEse) stylObj[selectorIDX] = 
			`.ripple-${ def.type == 'trigger' ? 'trigger' : 'element' }.${ selectorIDX }.ripple${ def.type == 'trigger' ? ' .ripple-target' : '' }::after {`+
				// `${ def.size !== 1 ? 'animation-name: rippleanim-'+def.size+'x;' : '' }`+
				`${ def.ease !== globEse ? 'animation-timing-function: '+def.ease+';' : '' }`+
				`${ (def.duration !== globDur && (/^([2-9]|10)x$/i).test(def.duration) === false) ? 'animation-duration: '+def.duration+'ms;' : '' }`+
			`}`
			let stylTxt = '';
			for(let s in stylObj) {
				stylTxt += stylObj[s];
			}
			stylFix.html(stylTxt);
		}
		return this;
	}
	// $.fn.rippleDismiss = function(ondown=false) {
	// 	return _it;
	// }
	return $;
}));