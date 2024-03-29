$ ->
  class FudeCursor
    constructor : (@size, @icon, @color) ->
      @x   = 0
      @y   = 0
      @css =
        "display"               : "none"
        "position"              : "absolute"
        "background-color"      : "#{@color}"
        "width"                 : "#{@size}px"
        "height"                : "#{@size}px"
        "border-radius"         : "#{@size}px"
        "-webkit-border-radius" : "#{@size}px"
        "-moz-border-radius"    : "#{@size}px"
        "cursor"                : "url(#{@icon}), pointer"
      @is_visible = false
      @target     = $("<div />").css(@css)
    show : () ->
      @is_visible = true
      @target.css { display : "block" }
    hide : () ->
      @is_visible = false
      @target.css { display : "none" }
    update : (x, y) ->
      @x = x
      @y = y
      this.move(x, y)
    move : (x, y) ->
      @target.css {
        top      : y - (@size / 2)
        left     : x - (@size / 2)
      }
    hit : (element) ->
      square = (num) -> return num * num
      x      = element.offset().left
      y      = element.offset().top
      x_end  = x + element.width()
      y_end  = y + element.height()
      a      = @x
      b      = @y
      r      = @size / 2
      return true if (x<a and a<x_end) and (y-r<b and b<y_end+r)
      return true if (y<b and b<y_end) and (x-r<a and a<x_end+r)
      return true if square(x-a)     + square(y-b)     < square(r) or
                     square(x-a)     + square(y_end-b) < square(r) or
                     square(x_end-a) + square(y-b)     < square(r) or
                     square(x_end-a) + square(y_end-b) < square(r)
      return false
    equal : (element) ->
      return @target.get(0) == $(element).get(0)

  class Fude
    constructor : (@target, option) ->
      @page_x = 0
      @page_y = 0
      @size   = option.size
      @icon   = option.icon
      @color  = option.color
      @cursor = new FudeCursor @size, @icon, @color
      this.set_task()
      this.set_event()
      this.set_cursor()
    set_event  : () ->
      that = this
      $("html").mousemove((e) ->
        that.page_x = e.pageX
        that.page_y = e.pageY
      )
      @target.click((e) ->
        $(this).find("*:visible").filter((index) ->
          return if that.cursor.equal(this)
          point = { x : that.page_x, y : that.page_y }
          $(this).trigger("fudeclick", point) if that.cursor.hit($(this))
        )
      )
    set_task   : () ->
      that = this
      task = () -> that.update()
      setInterval(task, 30)
    set_cursor : () ->
      @target.append(@cursor.target)
    update : () ->
      that = this
      @cursor.hide() if this.is_out() and @cursor.is_visible
      @cursor.show() if not this.is_out() and not @cursor.is_visible
      @cursor.update @page_x, @page_y
      @target.find("*:visible").filter((index) ->
        return if that.cursor.equal(this)
        element = $(this)
        point   = { x : that.page_x, y : that.page_y }
        if that.cursor.hit(element)
          element.trigger("fudemove", point)
          element.trigger("fudeover", point) if not jQuery.data(this, "over")
          jQuery.data(this, "over", 1)
        else
          element.trigger("fudeout", point) if jQuery.data(this, "over")
          jQuery.removeData(this)
      )
    is_out : () ->
      x      = @target.offset().left
      y      = @target.offset().top
      width  = @target.width()
      height = @target.height()
      return true if @page_x < x or @page_x > x + width
      return true if @page_y < y or @page_y > y + height
      return false

  $.fn.fude = (option) ->
    default_option =
      size  : 30
      icon  : "pointer.gif"
      color : "#000"
    return new Fude $(this), jQuery.extend(default_option, option)
