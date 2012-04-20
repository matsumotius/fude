$ ->
  class FudeCursor
    constructor : (@size, @icon) ->
      @x   = 0
      @y   = 0
      @css =
        "display"               : "none"
        "background-color"      : "#000"
        "position"              : "absolute"
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
      # hit check
    equal : (element) ->
      return @target.get(0) == $(element).get(0)

  class Fude
    constructor : (@target, option) ->
      @page_x = 0
      @page_y = 0
      @size   = 30
      @icon   = "pointer.gif"
      @cursor = new FudeCursor @size, @icon
      this.set_task()
      this.set_event()
      this.set_cursor()
    set_event  : () ->
      that = this
      $("html").mousemove((e) ->
        that.page_x = e.pageX
        that.page_y = e.pageY
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
      ###
      @target.find("*:visible").filter((index) ->
        return if that.cursor.equal(this)
        return if not that.cursor.hit(this)
        console.log "hit"
      )
      ###
    is_out : () ->
      x      = @target.offset().left
      y      = @target.offset().top
      width  = @target.width()
      height = @target.height()
      return true if @page_x < x or @page_x > x + width
      return true if @page_y < y or @page_y > y + height
      return false

  $.fn.fude = (option) ->
    return new Fude $(this), option
