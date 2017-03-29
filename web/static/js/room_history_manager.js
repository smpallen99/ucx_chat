import * as utils from "./utils"
import * as cc from "./chat_channel"
import * as main from "./main"

const start_conversation = `<li class="start color-info-font-color">${gettext.start_of_conversation}</li>`
const container = '.messages-box .wrapper ul'
const wrapper = '.messages-box .wrapper'
const debug = true

class RoomHistoryManager {
  constructor() {
    this.is_loading = false
    this.has_more = false
    this.has_more_next = false
    this.scroll_pos = {}
    this.current_room = undefined
    this.scroll_window = undefined

    setInterval(e => {
      this.update_scroll_pos()
    }, 1000)

    // console.log('roomHistoryManager.constructor', $(container).has('li.load-more'))
    if ($(container).has('li.load-more').length > 0) {
      console.log('length > 0')
      this.has_more = true
    }
  }

  get isLoading()   { return this.is_loading }
  get hasMore()     { return this.has_more }
  get hasMoreNext() { return this.has_more_next }

  set setHasMoreNext(on) {
    if (on) {
      $(wrapper).addClass('has-more-next')
      $('.jump-recent').removeClass('not')
    } else {
      $(wrapper).removeClass('has-more-next')
      $('.jump-recent').addClass('not')
    }
  }

  get_bottom_message() {
    let list = $(container + ' li[id]')
    let box = $(wrapper)[0].getBoundingClientRect()
    let found = list[list.length - 1]
    list.each((i, item) => {
      let msg_box = item.getBoundingClientRect()
      if (msg_box.bottom == box.bottom || msg_box.top < box.bottom && msg_box.bottom > box.bottom) {
        found = item
      }
    })
    return found
  }

  scroll_to_message(ts) {
    console.log('scroll_to_message', ts)
    // console.log('ts', ts)
    let target = $('.messages-box li[data-timestamp="' + ts + '"]')
    // console.log('target', target)

    if (target.offset()) {
      scroll_to(target)
    } else {
      this.getSurroundingMessages(ts)
    }
  }

  fix_new_days() {
    let list = $(container + ' li[id]')
    let last = list.length - 1
    for (let i = 0; i < last - 1; i++) {
      let item = list[i]
      if ($(item).hasClass('new-day') && i > 0) {
        if ($(item).data('date') == $(list[i - 1]).data('date'))
          $('#' + $(item).attr('id')).removeClass('new-day')
      }
    }
  }

  cache_room() {
    if (ucxchat.channel_id)
      this.cached_scrollTop = $(wrapper)[0].scrollTop
  }
  restore_cached_room() {
    if (ucxchat.channel_id) {
      $(wrapper)[0].scrollTop = this.cached_scrollTop
      roomManager.bind_history_manager_scroll_event()
    }
  }

  get getMore() {
    if (debug) { console.log('roomHistoryManager.getMore()')}
    let html = $('.messages-box .wrapper ul').html()
    let first_id = $('.messages-box .wrapper ul li[id]').first().attr('id')

    this.is_loading = true

    utils.page_loading()
    this.startGetMoreAnimation()

    cc.get('/messages', {timestamp: $('li.message').first().attr('data-timestamp')})
      .receive("ok", resp => {
        if (debug) { console.log('got response back from loading', resp) }

        $(container)[0].innerHTML = resp.html + html

        if (debug) { console.log('finished loading', first_id) }

        this.startGetMoreAnimation()

        scroll_to($('#' + first_id), -80)
        utils.remove_page_loading()

        this.fix_new_days()

        if (!resp.has_more) {
          $(container).children().first().addClass('new-day')
          $(container).prepend(start_conversation)
        } else {
          $('li.load-more').remove()
          $(container).prepend(utils.loadmore())
        }
        this.is_loading = false
        this.has_more = resp.has_more
        main.run()
      })
  }
  get getMoreNext() {
    let html = $(container).html()
    let ts = $('.messages-box li[data-timestamp]').last().data('timestamp')
    let last_id = $('.messages-box li[data-timestamp]').last().attr('id')
    utils.page_loading()
    this.startGetMoreNextAnimation()
    this.is_loading = true

    cc.get('/messages/previous', {timestamp: ts})
      .receive("ok", resp => {
        if (debug) { console.log('getMoreNext resp', resp)}
        $('.messages-box .wrapper ul li:last.load-more').addClass('load-more-next')

        $('.messages-box .wrapper ul')[0].innerHTML = html + resp.html

        scroll_to($('#' + last_id), 400)
        $('.load-more-next').remove()
        if (resp.has_more_next) {
          this.setHasMoreNext = true
          $('.messages-box .wrapper ul').append(utils.loadmore())
        } else {
          this.setHasMoreNext = false
        }

        this.is_loading = false
        this.has_more_next = resp.has_more_next
        main.run()
      })
  }

  new_room(room) {
    // console.log('new_room', room)
    this.current_room = room
    this.is_loading = false
    // this.has_more = false
    // this.has_more_next = false
  }

  scroll_new_window() {
    this.scroll_window = $(wrapper)[0]
    if (!this.scroll_pos[this.current_room]) {
      // console.log('scroll_new_window this.current_room', this.current_room)
      userchan.push("get:currentMessage", {room: this.current_room})
        .receive("ok", resp => {
          // console.warn('scroll_new_window ok resp', resp)
          this.set_scroll_top("ok", resp)
        })
        .receive("error", resp => {
          // console.warn('scroll_new_window err resp', resp)
          this.set_scroll_top("error", resp)
        })
    } else {
      // console.warn('scroll_new_window else this', this)
      this.set_scroll_top("ok", {value: this.scroll_pos[this.current_room]})
    }
  }

  set_scroll_top(code, resp) {
    if (resp.value == "") {
      let elem = $(container)
      // console.log('set_scroll_top 1 value', resp, elem, elem.parent().scrollTop())
      utils.scroll_bottom()
    } else {
      console.log('set_scroll_top 2 value', resp)
      if (code == "ok") {
        this.scroll_to_message(resp.value)
      } else {
        utils.scroll_bottom()
      }
    }
  }

  update_scroll_pos() {
    if (!this.is_loading && this.scroll_window && $(wrapper).length > 0) {
      let current_message = this.bottom_message_ts()
      if ((current_message != this.scroll_pos[this.current_room])) {
        this.scroll_pos[this.current_room] = current_message
        if (current_message && current_message != "")
          userchan.push("update:currentMessage", {value: current_message})
      }
    }
  }

  getSurroundingMessages(timestamp) {
    if (debug) { console.log("jump-to need to load some messages", timestamp) }
    this.is_loading = true
    utils.page_loading()
    $('.messages-box .wrapper ul li.load-more').html(utils.loading_animation())
    cc.get('/messages/surrounding', {timestamp: timestamp})
      .receive("ok", resp => {
        $(container)[0].innerHTML = resp.html
        let message_id = $(`.messages-box li[data-timestamp="${timestamp}"]`).attr('id')
        console.log('message_id', message_id)
        if (message_id) {
          scroll_to($('#' + message_id), -200)
        } else {
          console.error('invalid timestamp', timestamp)
        }
        if (resp.has_more_next) {
          this.setHasMoreNext = true
          $('.messages-box .wrapper ul:last').append(utils.loadmore())
        } else {
          this.setHasMoreNext = false
        }
        if (resp.has_more) {
          $('.messages-box .wrapper ul').prepend(utils.loadmore())
        }
        utils.remove_page_loading()
        this.has_more_next = resp.has_more_next
        this.has_more = resp.has_more
        this.is_loading = false
        main.run()
      })
  }

  getRecent() {
    utils.page_loading()
    $(container).prepend(utils.loadmore_with_animation())
    utils.page_loading()
    this.is_loading = true

    cc.get('/messages/last')
      .receive("ok", resp => {
        $('.messages-box .wrapper ul')[0].innerHTML = resp.html
        $(container + ' li:first.load-more').remove()
        $('.messages-box .wrapper').animate({
          scrollTop: utils.getScrollBottom()
        }, 1000);
        this.setHasMoreNext = false
        this.has_more_next = false
        this.has_more = true
        this.is_loading = false
        main.run()
      })
  }
  bottom_message_ts() {
    let cm = this.get_bottom_message()
    if (cm)
      return cm.getAttribute('data-timestamp')
  }

  startGetMoreAnimation() {
    if (debug) { console.log('startGetMoreAnimation') }
    $('.messages-box .wrapper ul li:first.load-more').html(utils.loading_animation())
  }
  startGetMoreNextAnimation() {
    if (debug) { console.log('startGetMoreNextAnimation') }
    this.removeGetMoreNextAnimation()
    $(container).append(utils.loadmore_with_animation())
  }
  removeGetMoreAnimation() {
    if (debug) { console.log('removeGetMoreAnimation') }
    $('.messages-box .wrapper ul > li:first.load-more').remove()
  }
  removeGetMoreNextAnimation() {
    if (debug) { console.log('removeGetMoreNextAnimation') }
    $('.messages-box .wrapper ul > li:last.load-more').remove()
  }
}

export default RoomHistoryManager

