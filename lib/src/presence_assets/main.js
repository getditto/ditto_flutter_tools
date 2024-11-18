/*! For license information please see main.js.LICENSE.txt *".run(2)
 *
var Presence;(()=>{var e={698:(e,t,i)=>{"use strict";i.r(t)},400:function(e){var t;"undefined"!=typeof self&&self,t=function(){return function(e){var t={};function i(o){if(t[o])return t[o].exports;var n=t[o]={i:o,l:!1,exports:{}};return e[o].call(n.exports,n,n.exports,i),n.l=!0,n.exports}return i.m=e,i.c=t,i.d=function(e,t,o){i.o(e,t)||Object.defineProperty(e,t,{configurable:!1,enumerable:!0,get:o})},i.n=function(e){var t=e&&e.__esModule?function(){return e.default}:function(){return e};return i.d(t,"a",t),t},i.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},i.p="",i(i.s=85)}([function(e,t,i){"use strict";t.__esModule=!0,t.default=function(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}},function(e,t,i){"use strict";t.__esModule=!0;var o,n=(o=i(130))&&o.__esModule?o:{default:o};t.default=function(){function e(e,t){for(var i=0;i<t.length;i++){var o=t[i];o.enumerable=o.enumerable||!1,o.configurable=!0,"value"in o&&(o.writable=!0),(0,n.default)(e,o.key,o)}}return function(t,i,o){return i&&e(t.prototype,i),o&&e(t,o),t}}()},function(e,t,i){"use strict";var o=a(i(58)),n=a(i(31)),s=a(i(9)),r=a(i(7));function a(e){return e&&e.__esModule?e:{default:e}}var d=i(71),h=i(119);function l(e,t,i,o){var n=!1;!0===o&&(n=null===t[i]&&void 0!==e[i]),n?delete e[i]:e[i]=t[i]}t.isNumber=function(e){return e instanceof Number||"number"==typeof e},t.recursiveDOMDelete=function(e){if(e)for(;!0===e.hasChildNodes();)t.recursiveDOMDelete(e.firstChild),e.removeChild(e.firstChild)},t.isString=function(e){return e instanceof String||"string"==typeof e},t.isDate=function(e){if(e instanceof Date)return!0;if(t.isString(e)){if(u.exec(e))return!0;if(!isNaN(Date.parse(e)))return!0}return!1},t.randomUUID=function(){return h.v4()},t.fillIfDefined=function(e,i){var o=arguments.length>2&&void 0!==arguments[2]&&arguments[2];for(var n in e)void 0!==i[n]&&(null===i[n]||"object"!==(0,r.default)(i[n])?l(e,i,n,o):"object"===(0,r.default)(e[n])&&t.fillIfDefined(e[n],i[n],o))},t.extend=function(e){for(var t=1;t<arguments.length;t++){var i=arguments[t];for(var o in i)i.hasOwnProperty(o)&&(e[o]=i[o])}return e},t.selectiveExtend=function(e,t){if(!Array.isArray(e))throw new Error("Array with property names expected as first argument");for(var i=2;i<arguments.length;i++)for(var o=arguments[i],n=0;n<e.length;n++){var s=e[n];o&&o.hasOwnProperty(s)&&(t[s]=o[s])}return t},t.selectiveDeepExtend=function(e,i,o){var n=arguments.length>3&&void 0!==arguments[3]&&arguments[3];if(Array.isArray(o))throw new TypeError("Arrays are not supported by deepExtend");for(var s=0;s<e.length;s++){var r=e[s];if(o.hasOwnProperty(r))if(o[r]&&o[r].constructor===Object)void 0===i[r]&&(i[r]={}),i[r].constructor===Object?t.deepExtend(i[r],o[r],!1,n):l(i,o,r,n);else{if(Array.isArray(o[r]))throw new TypeError("Arrays are not supported by deepExtend");l(i,o,r,n)}}return i},t.selectiveNotDeepExtend=function(e,i,o){var n=arguments.length>3&&void 0!==arguments[3]&&arguments[3];if(Array.isArray(o))throw new TypeError("Arrays are not supported by deepExtend");for(var s in o)if(o.hasOwnProperty(s)&&-1===e.indexOf(s))if(o[s]&&o[s].constructor===Object)void 0===i[s]&&(i[s]={}),i[s].constructor===Object?t.deepExtend(i[s],o[s]):l(i,o,s,n);else if(Array.isArray(o[s])){i[s]=[];for(var r=0;r<o[s].length;r++)i[s].push(o[s][r])}else l(i,o,s,n);return i},t.deepExtend=function(e,i){var o=arguments.length>2&&void 0!==arguments[2]&&arguments[2],n=arguments.length>3&&void 0!==arguments[3]&&arguments[3];for(var s in i)if(i.hasOwnProperty(s)||!0===o)if(i[s]&&i[s].constructor===Object)void 0===e[s]&&(e[s]={}),e[s].constructor===Object?t.deepExtend(e[s],i[s],o):l(e,i,s,n);else if(Array.isArray(i[s])){e[s]=[];for(var r=0;r<i[s].length;r++)e[s].push(i[s][r])}else l(e,i,s,n);return e},t.equalArray=function(e,t){if(e.length!=t.length)return!1;for(var i=0,o=e.length;i<o;i++)if(e[i]!=t[i])return!1;return!0},t.convert=function(e,i){var o;if(void 0!==e){if(null===e)return null;if(!i)return e;if("string"!=typeof i&&!(i instanceof String))throw new Error("Type must be a string");switch(i){case"boolean":case"Boolean":return Boolean(e);case"number":case"Number":return t.isString(e)&&!isNaN(Date.parse(e))?d(e).valueOf():Number(e.valueOf());case"string":case"String":return String(e);case"Date":if(t.isNumber(e))return new Date(e);if(e instanceof Date)return new Date(e.valueOf());if(d.isMoment(e))return new Date(e.valueOf());if(t.isString(e))return(o=u.exec(e))?new Date(Number(o[1])):d(new Date(e)).toDate();throw new Error("Cannot convert object of type "+t.getType(e)+" to type Date");case"Moment":if(t.isNumber(e))return d(e);if(e instanceof Date)return d(e.valueOf());if(d.isMoment(e))return d(e);if(t.isString(e))return o=u.exec(e),d(o?Number(o[1]):e);throw new Error("Cannot convert object of type "+t.getType(e)+" to type Date");case"ISODate":if(t.isNumber(e))return new Date(e);if(e instanceof Date)return e.toISOString();if(d.isMoment(e))return e.toDate().toISOString();if(t.isString(e))return(o=u.exec(e))?new Date(Number(o[1])).toISOString():d(e).format();throw new Error("Cannot convert object of type "+t.getType(e)+" to type ISODate");case"ASPDate":if(t.isNumber(e))return"/Date("+e+")/";if(e instanceof Date)return"/Date("+e.valueOf()+")/";if(t.isString(e))return"/Date("+((o=u.exec(e))?new Date(Number(o[1])).valueOf():new Date(e).valueOf())+")/";throw new Error("Cannot convert object of type "+t.getType(e)+" to type ASPDate");default:throw new Error('Unknown type "'+i+'"')}}};var u=/^\/?Date\((\-?\d+)/i;t.getType=function(e){var t=void 0===e?"undefined":(0,r.default)(e);return"object"==t?null===e?"null":e instanceof Boolean?"Boolean":e instanceof Number?"Number":e instanceof String?"String":Array.isArray(e)?"Array":e instanceof Date?"Date":"Object":"number"==t?"Number":"boolean"==t?"Boolean":"string"==t?"String":void 0===t?"undefined":t},t.copyAndExtendArray=function(e,t){for(var i=[],o=0;o<e.length;o++)i.push(e[o]);return i.push(t),i},t.copyArray=function(e){for(var t=[],i=0;i<e.length;i++)t.push(e[i]);return t},t.getAbsoluteLeft=function(e){return e.getBoundingClientRect().left},t.getAbsoluteRight=function(e){return e.getBoundingClientRect().right},t.getAbsoluteTop=function(e){return e.getBoundingClientRect().top},t.addClassName=function(e,t){var i=e.className.split(" "),o=t.split(" ");i=i.concat(o.filter((function(e){return i.indexOf(e)<0}))),e.className=i.join(" ")},t.removeClassName=function(e,t){var i=e.className.split(" "),o=t.split(" ");i=i.filter((function(e){return o.indexOf(e)<0})),e.className=i.join(" ")},t.forEach=function(e,t){var i,o;if(Array.isArray(e))for(i=0,o=e.length;i<o;i++)t(e[i],i,e);else for(i in e)e.hasOwnProperty(i)&&t(e[i],i,e)},t.toArray=function(e){var t=[];for(var i in e)e.hasOwnProperty(i)&&t.push(e[i]);return t},t.updateProperty=function(e,t,i){return e[t]!==i&&(e[t]=i,!0)},t.throttle=function(e){var t=!1;return function(){t||(t=!0,requestAnimationFrame((function(){t=!1,e()})))}},t.addEventListener=function(e,t,i,o){e.addEventListener?(void 0===o&&(o=!1),"mousewheel"===t&&navigator.uq