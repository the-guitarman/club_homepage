import _ from 'underscore';
window._ = window.underscore = _;

let matchTimelineJavascriptExtensions = {
  extendDate: () => {
    Date.prototype.toISOString = function() {
      var pad = function(number) {
        var r = String(number);
        if ( r.length === 1 ) {
          r = '0' + r;
        }
        return r;
      };

      return this.getUTCFullYear() +
        '-' + pad( this.getUTCMonth() + 1 ) +
        '-' + pad( this.getUTCDate() ) +
        'T' + pad( this.getUTCHours() ) +
        ':' + pad( this.getUTCMinutes() ) +
        ':' + pad( this.getUTCSeconds() ) +
        '.' + String( (this.getUTCMilliseconds()/1000).toFixed(3) ).slice( 2, 5 ) +
        'Z';
    };
  },

  extendUnderscore: () => {
    _.mixin({
      "eachSlice": function(obj, size, iterator, context) {
        for (var i=0, l=obj.length; i < l; i+=size) {
          iterator.call(context, obj.slice(i,i+size), i, obj);
        } 
      }
    });
  },

  init: () => {
    matchTimelineJavascriptExtensions.extendDate();
    matchTimelineJavascriptExtensions.extendUnderscore();
  }
};

export default matchTimelineJavascriptExtensions;
