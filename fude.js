// Generated by CoffeeScript 1.3.1

$(function() {
  var Fude, FudeCursor;
  FudeCursor = (function() {

    FudeCursor.name = 'FudeCursor';

    function FudeCursor(size, icon, color) {
      this.size = size;
      this.icon = icon;
      this.color = color;
      this.x = 0;
      this.y = 0;
      this.css = {
        "display": "none",
        "position": "absolute",
        "background-color": "" + this.color,
        "width": "" + this.size + "px",
        "height": "" + this.size + "px",
        "border-radius": "" + this.size + "px",
        "-webkit-border-radius": "" + this.size + "px",
        "-moz-border-radius": "" + this.size + "px",
        "cursor": "url(" + this.icon + "), pointer"
      };
      this.is_visible = false;
      this.target = $("<div />").css(this.css);
    }

    FudeCursor.prototype.show = function() {
      this.is_visible = true;
      return this.target.css({
        display: "block"
      });
    };

    FudeCursor.prototype.hide = function() {
      this.is_visible = false;
      return this.target.css({
        display: "none"
      });
    };

    FudeCursor.prototype.update = function(x, y) {
      this.x = x;
      this.y = y;
      return this.move(x, y);
    };

    FudeCursor.prototype.move = function(x, y) {
      return this.target.css({
        top: y - (this.size / 2),
        left: x - (this.size / 2)
      });
    };

    FudeCursor.prototype.hit = function(element) {
      var a, b, r, square, x, x_end, y, y_end;
      square = function(num) {
        return num * num;
      };
      x = element.offset().left;
      y = element.offset().top;
      x_end = x + element.width();
      y_end = y + element.height();
      a = this.x;
      b = this.y;
      r = this.size / 2;
      if ((x < a && a < x_end) && (y - r < b && b < y_end + r)) {
        return true;
      }
      if ((y < b && b < y_end) && (x - r < a && a < x_end + r)) {
        return true;
      }
      if (square(x - a) + square(y - b) < square(r) || square(x - a) + square(y_end - b) < square(r) || square(x_end - a) + square(y - b) < square(r) || square(x_end - a) + square(y_end - b) < square(r)) {
        return true;
      }
      return false;
    };

    FudeCursor.prototype.equal = function(element) {
      return this.target.get(0) === $(element).get(0);
    };

    return FudeCursor;

  })();
  Fude = (function() {

    Fude.name = 'Fude';

    function Fude(target, option) {
      this.target = target;
      this.page_x = 0;
      this.page_y = 0;
      this.size = option.size;
      this.icon = option.icon;
      this.color = option.color;
      this.cursor = new FudeCursor(this.size, this.icon, this.color);
      this.set_task();
      this.set_event();
      this.set_cursor();
    }

    Fude.prototype.set_event = function() {
      var that;
      that = this;
      $("html").mousemove(function(e) {
        that.page_x = e.pageX;
        return that.page_y = e.pageY;
      });
      return this.target.click(function(e) {
        return $(this).find("*:visible").filter(function(index) {
          var point;
          if (that.cursor.equal(this)) {
            return;
          }
          point = {
            x: that.page_x,
            y: that.page_y
          };
          if (that.cursor.hit($(this))) {
            return $(this).trigger("fudeclick", point);
          }
        });
      });
    };

    Fude.prototype.set_task = function() {
      var task, that;
      that = this;
      task = function() {
        return that.update();
      };
      return setInterval(task, 30);
    };

    Fude.prototype.set_cursor = function() {
      return this.target.append(this.cursor.target);
    };

    Fude.prototype.update = function() {
      var that;
      that = this;
      if (this.is_out() && this.cursor.is_visible) {
        this.cursor.hide();
      }
      if (!this.is_out() && !this.cursor.is_visible) {
        this.cursor.show();
      }
      this.cursor.update(this.page_x, this.page_y);
      return this.target.find("*:visible").filter(function(index) {
        var element, point;
        if (that.cursor.equal(this)) {
          return;
        }
        element = $(this);
        point = {
          x: that.page_x,
          y: that.page_y
        };
        if (that.cursor.hit(element)) {
          element.trigger("fudemove", point);
          if (!jQuery.data(this, "over")) {
            element.trigger("fudeover", point);
          }
          return jQuery.data(this, "over", 1);
        } else {
          if (jQuery.data(this, "over")) {
            element.trigger("fudeout", point);
          }
          return jQuery.removeData(this);
        }
      });
    };

    Fude.prototype.is_out = function() {
      var height, width, x, y;
      x = this.target.offset().left;
      y = this.target.offset().top;
      width = this.target.width();
      height = this.target.height();
      if (this.page_x < x || this.page_x > x + width) {
        return true;
      }
      if (this.page_y < y || this.page_y > y + height) {
        return true;
      }
      return false;
    };

    return Fude;

  })();
  return $.fn.fude = function(option) {
    var default_option;
    default_option = {
      size: 30,
      icon: "pointer.gif",
      color: "#000"
    };
    return new Fude($(this), jQuery.extend(default_option, option));
  };
});
