import Messages from "./messages"
import Favico from "./favico"
import * as socket from './socket'
import * as cc from "./chat_channel"
import * as utils from './utils'
import sweetAlert from "./sweetalert.min"
import toastr from 'toastr'

const debug = true;
const new_message_unread_time = 5000;
const container = '.messages-box .wrapper ul'
const wrapper = '.messages-box .wrapper'

class RoomManager {
  constructor() {
    this.badges = 0
    this.register_events()
    this.view_elem = $('.messages-box .wrapper')[0];
    if (this.view_elem) {
      this.rect = this.view_elem.getBoundingClientRect()
      this.focus = false
      this.unread = ucxchat.unread
      this.unread_list = []
      this.new_message_ref = undefined
      this.at_bottom = true
      this.new_message_button = false
      this.unread_timer_ref = undefined
    }

    this.favico = new Favico({
      position : 'up',
      animation : 'pop'
      // animation : 'popFade'
    })
    this.title = document.title.replace(/\(.*?\)/, '')
    this.set_badges()
    $('textarea.input-message').autogrow({
      postGrowCallback: function() { this.resize }
    })
  }

  get bounding() { return this.rect; }

  get has_focus() { return this.focus; }
  set has_focus(val) {
    if (val && this.new_message_ref) {
      clearTimeout(this.new_message_ref);
    }
    this.focus = val;
  }

  get is_unread() { return this.unread; }
  set is_unread(val) { this.unread = val; }

  render_room(resp) {
    if (debug) { console.log('render_room resp', resp) }
    $('.room-link').removeClass("active")
    $('.main-content').html(resp.html)
    let last_read = resp.messages_info.last_read
    if (last_read && last_read != "") {
      setTimeout(() => {
        let lr_elem = $(`li.message[data-timestamp="${last_read}"]`)
        let next = lr_elem.next('li.message')
        if (next.length > 0) {
          this.unread = true
          lr_elem.nextAll('li.message').each((i, elem) => {
            this.unread_list.push($(elem).attr('id'))
          })
          utils.scroll_bottom()
          next.addClass('first-unread')
        }
      }, 2000)
    }
    ucxchat.channel_id = resp.channel_id
    ucxchat.room = resp.room_title
    ucxchat.display_name = resp.display_name
    ucxchat.room_route = resp.room_route
    chat_settings.allow_upload = resp.allow_upload
    if (resp.side_nav_html) {
      $('aside .rooms-list').html(resp.side_nav_html)
    }
    $('.room-title').html(ucxchat.display_name)
    $('.link-room-' + ucxchat.room).addClass("active")
    utils.scroll_bottom()
    roomchan.leave()
    socket.restart_socket()
  }
  toggle_favorite() {
    if (debug) { console.log('toggle_favorite') }
    cc.put("/room/favorite")
      .receive("ok", resp => {
        $('.messages-container .fixed-title h2').html(resp.messages_html)
        $('aside .rooms-list').html(resp.side_nav_html)
      })
  }
  add_private(elem) {
    let username = elem.parent().attr('data-username')
    if (debug) { console.log('pvt-msg button clicked...', username) }
    console.log('location')
    window.location = '/direct/' + username
  }
  update(msg) {
    if(debug) { console.log('update...', msg) }
    let fname = msg.field_name
    if ( fname == "topic"  || fname == "title" || fname == "description") {
      $('.room-' + fname).html(msg.value)
    } else if (fname == "name") {
      $('.room-title').html(msg.value)
      ucxchat.room = msg.value
      ucxchat.display_name = msg.value
      utils.replace_history()
    }
    setTimeout(() => {
      $('span.current-setting[data-edit="' + fname + '"]').text(msg.value)
    }, 100)

  }
  room_mention(resp) {
    let parent = `a.open-room[data-room="${resp.room}"]`
    let elem = $(parent + ' span.unread')
    if (debug) { console.log('room_manager', resp, elem) }
    if (elem.length == 0) {
      $(parent).prepend(`<span class="unread">${resp.unread}</span>`)
    } else {
      elem.text(resp.unread)
    }
  }
  update_burger_alert() {
    if($('.rooms-list li.has-alert').length > 0) {
      let count = 0
      for (const has_unread of $('li.room-link span.unread')) {
        count += parseInt($(has_unread).text())
      }
      this.set_burger_unreads(count)
    } else {
      this.clear_burger_unreads()
    }
  }
  set_burger_unreads(count) {
    let value = '•'
    if (count > 0) { value = count }
    let alert = `<div class="unread-burger-alert color-error-contrast background-error-color">${value}</div>`
    if ($('.burger .unread-burger-alert').length > 0) {
      $('.burger .unread-burger-alert').text(value)
    } else {
      $('.burger').append(alert)
    }
  }
  clear_burger_unreads() {
    $('.burger .unread-burger-alert').remove()
  }

  notification(resp) {
    if (!resp.badges_only) {
      if (resp.body) {
        desktop_notifier.notify('@' + resp.username, resp.body, resp.duration)
      }
      if (resp.sound) {
        desktop_notifier.notify_audio(resp.sound)
      }
    }
    this.set_badges()
  }

  message_box_focus() {
    $('.input-messgae').focus()
  }

  updateMentionsMarksOfRoom() {
    let dom = document
    let ticksBar = $(dom).find('.ticks-bar')

    $(dom).find('.ticks-bar > .tick').remove()

    let scrollTop = $(dom).find('.messages-box > .wrapper').scrollTop() - 50
    let totalHeight = $(dom).find('.messages-box > .wrapper > ul').height() + 40

    $('.messages-box .mention-link-me').each((index, item) => {
      let topOffset = $(item).offset().top + scrollTop
      let percent = 100 / totalHeight * topOffset
      if ($(item).hasClass('mention-link-all'))
        ticksBar.append('<div class="tick background-attention-color" style="top: '+percent+'%;"></div>')
      else
        ticksBar.append('<div class="tick background-primary-action-color" style="top: '+percent+'%;"></div>')
    })
  }

  count_unread() {
    var count = 0
    var p = this;
    this.unread_list.every(function(id) {
      if (p.is_visible($('#' + id))) {
        return false;
      } else {
        count++;
        return true;
      }
    })
    return count;
  }


  has_first_unread() {
    return $('.first-unread').length > 0;
  }

  hide_unread_bar() {
    let bar = $('.unread-bar')
    if (bar.length > 0) {
      bar.hide()
    }
  }

  is_first_unread_visible() {
    return this.is_visible($('.first-unread'))
  }

  is_unread_bar_visible() {
    return $('.unread-bar').is(':visible')
  }

  is_visible(jelem) {
    if (jelem.length > 0) {
      let elem = jelem[0]
      let eb = elem.getBoundingClientRect()
      if (eb.top > this.rect.top && eb.bottom < this.rect.bottom) {
        return true
      } else if (eb.top <= this.rect.top && eb.bottom >= this.rect.bottom) {
        return true
      } else {
        return false
      }
    } else {
      return false
    }
  }

  set_unread(id) {
    if (debug) { console.log('set_unread value', this.is_unread) }
    if (!this.is_unread) {
      cc.put("/room/has_unread")
    }
    $('.first-unread').removeClass('first-unread').removeClass('first-unread-opaque')
    $('#' + id).addClass('first-unread')
    $('li.link-room-'+ucxchat.room).addClass('has-unread').addClass('has-alert')
    this.is_unread = true;
    this.update_burger_alert()
  }

  new_message(id, user_id) {
    if (user_id != ucxchat.user_id) {
      if (!this.focus && !this.unread) {
        this.set_unread(id)
      }

      if (this.unread || this.new_message_ref) {
        if (debug) { console.log('new_message pushing id') }
        this.unread_list.push(id)
      } else {
        if (debug) { console.log('new_message not pushing id') }
        this.send_last_read()
      }
      if (!this.new_message_button && !this.at_bottom) {
        this.add_new_message_button()
      }
    } else {
      if ($('.first-unread').length > 0)
        this.clear_all_unreads()
      this.send_last_read()
    }
    this.update_burger_alert()
  }

  add_new_message_button() {
    this.new_message_button = true
    $('button.new-message').removeClass('not')
  }

  remove_new_message_button() {
    this.new_message_button = false
    $('button.new-message').addClass('not')
  }

  send_last_read() {
    let ts = $(container + ' li[id]:last').data('timestamp')
    userchan.push('last_read', {last_read: ts})
  }

  push_channel(message, args={}) {
    setTimeout(function() {
      cc.push(message, args)
    }, 20)
  }

  remove_unread() {
    if (debug) { console.log('remove_unread') }
    if (this.is_first_unread_visible() || !this.unread) {
      if (debug) { console.log('remove_unread removeing...') }
      this.clear_unread()
    }
  }

  remove_unread_class() {
    if (this.has_first_unread()) {
      $('.first-unread').removeClass('first-unread first-unread-opaque')
      this.push_channel('unread:clear')
      this.unread = false
    }
  }

  new_room() {
    if (debug) { console.log('new_room', this)}
    this.has_more = $('.messages-box li.load-more').length > 0
    roomHistoryManager.new_room(ucxchat.room)
    this.updateMentionsMarksOfRoom()

    let html = $('.messages-box .wrapper ul').html()
    $('.messages-box .wrapper ul').html(html)

    $('.messages-box .wrapper ul .body img.emojione').each((i, elem) => {
      if ($(elem).closest('.body').text().trim() == "") {
        $(elem).addClass('big')
      }
    })

    roomchan.on('room:open', resp => {
      utils.page_loading()
      $('.main-content').html(utils.loading_animation())
      this.open_room(resp.room, resp.room)
      if (resp.state) {
        this.focus = true
      } else {
        this.focus = false
      }
    })
  }

  bind_history_manager_scroll_event() {
    if (!ucxchat.channel_id) {
      return false
    }
    $('.messages-box .wrapper').bind('scroll', _.throttle((e) => {
      let at_bottom = e.currentTarget.scrollTop >= e.currentTarget.scrollHeight - e.currentTarget.clientHeight - 80
      this.at_bottom = at_bottom
      if (at_bottom && this.new_message_button) {
        this.remove_new_message_button()
      }
      if (!roomHistoryManager.isLoading && (roomHistoryManager.hasMore || roomHistoryManager.hasMoreNext)) {
        if (roomHistoryManager.hasMore && e.currentTarget.scrollTop == 0)
          roomHistoryManager.getMore
        else if (roomHistoryManager.hasMoreNext && at_bottom)
          roomHistoryManager.getMoreNext
      }
      // console.log('scrolling.... unread', this.unread)
      if (this.unread) {
        if (debug) { console.log('scrolling unread') }

        if (this.is_first_unread_visible()) {
          if (debug) { console.log('hiding unread_bar') }
            if ($('.unread-bar').is(':visible')) {
              this.hide_unread_bar()
              this.clear_unread()
              this.send_last_read()
            }
        } else {
          if (this.unread_timer_ref) {
            clearTimeout(this.unread_timer_ref)
            this.unread_timer_ref = undefined
          }
          let count = this.count_unread()
          if ($('.first-unread').length > 0 && !$('.unread-bar').is(':visible')) {
            $('.unread-bar').show()
            if (debug) { console.log('show unread bar') }
          } else {
            if (debug) { console.log('else dont show unread bar') }
          }
          $('.unread-cnt').html(count)
          if (debug) { console.log('count', count) }
        }
      }
    }, 200))
  }

  scroll_to(elem, offset = 0) {
    let offst = offset
    let msgbox = $('.messages-box .wrapper')
    console.log('msgbox', msgbox, 'elem', elem)
    let valof = msgbox.scrollTop().valueOf()
    let offtop = msgbox.offset().top
    let item_top = elem.offset().top
    if (offset == 0) {
      offst = -$(msgbox).height() + elem.height() - 5
    }
    let val = msgbox.scrollTop().valueOf() + item_top - msgbox.offset().top + offst
    $('.messages-box .wrapper').scrollTop(val)
  }

  clear_unread() {
    if (!this.unread_timer_ref) {
      this.unread_timer_ref = setTimeout(() => {
        cc.delete_('/room/has_unread')
        this.clear_navbar()
        this.clear_unread_state()
        $('.first-unread').addClass('first-unread-opaque')
        this.set_badges()
      }, 2000)
    }
  }

  clear_all_unreads() {
    this.remove_new_message_button()
    this.remove_unread_class()
    this.clear_navbar()
    this.clear_unread_state()
    $('.first-unread').removeClass('first-unread first-unread-opaque')
  }

  clear_unread_state() {
    this.unread = false;
    this.unread_list = [];

    if (this.unread_timer_ref) {
      clearTimeout(this.unread_timer_ref)
      this.unread_timer_ref = undefined
    }
  }

  clear_navbar() {
    let parent = `a.open-room[data-room="${ucxchat.room}"]`
    $(parent + ' span.unread').remove()
    $('li.link-room-' + ucxchat.room).removeClass('has-alert').removeClass('has-unread')
  }


  open_room(room, display_name, callback) {
    if (debug) { console.log('open_room', this) }
    cc.get("/room/" + room, {display_name: display_name, room: ucxchat.room})
      .receive("ok", resp => {
        if (resp.redirect) {
          console.log('location')
          window.location = resp.redirect
        } else {
          this.render_room(resp)
          this.bind_history_manager_scroll_event()
        }
        if (callback) { callback() }
        utils.remove_page_loading()
      })
  }

  get_unreads() {
    let unread = 0
    $('span.unread').each(function(inx, unr) {
      unread += parseInt($(unr).text())
    })
    return unread
  }

  set_badges() {
    let cnt = this.get_unreads()
    if (cnt != this.badges) {
      this.badges = cnt
      if (cnt == 0) {
        // document.title = this.title
        this.favico.reset()
      } else {
        // document.title = `(${cnt}) ${this.title}`
        this.favico.badge(this.badges)
      }
    }
    this.update_burger_alert()
  }

  register_events() {
    this.bind_history_manager_scroll_event()

    $(window).on('focus', () => {
      if (debug) { console.log('room_manager focus') }
      this.clear_unread()
      this.has_focus = true
      if (systemchan) {
        systemchan.push('state:focus')
      }
    })
    .on('blur', () => {
      this.has_focus = false;
      if (systemchan) {
        systemchan.push('state:blur')
        if (debug) { console.log('room_manager blur') }
      }
    })

    $('body').on('click', 'a.open-room', e => {
      e.preventDefault();
      if (debug) { console.log('clicked a.open-room', e, $(e.currentTarget), $(e.currentTarget).attr('data-room')) }
      utils.page_loading()
      $('.main-content').html(utils.loading_animation())
      this.open_room($(e.currentTarget).attr('data-room'), $(e.currentTarget).attr('data-name'))
    })
    .on('click', 'a.toggle-favorite', e => {
      if (debug) { console.log('click a.toggle-favorite') }
      e.preventDefault();
      this.toggle_favorite()
    })
    .on('click', '.button.pvt-msg', e => {
      if (debug) { console.log('click .button.pvt-msg') }
      e.preventDefault();
      this.add_private($(e.currentTarget))
    })
    .on('click', 'button.set-owner', e => {
      let username = $(e.currentTarget).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/set-owner/" + username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    .on('click', 'button.unset-owner', e => {
      let username = $(e.currentTarget).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/unset-owner/" + username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    .on('click', 'button.set-moderator', e => {
      let username = $(e.currentTarget).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/set-moderator/" + username)
        .receive("ok", resp => {
          if (resp.redirect) {
            if (debug) { console.log('location') }
            window.location = resp.redirect
          }
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    .on('click', 'button.unset-moderator', e => {
      let username = $(e.currentTarget).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/unset-moderator/" + username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    .on('click', 'button.unmute-user', e => {
      let username = $(e.currentTarget).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/unmute-user/" + username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    .on('click', 'button.unblock-user', e => {
      let username = $(e.currentTarget).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/unblock-user/" + username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    .on('click', 'button.block-user', e => {
      let username = $(e.currentTarget).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/block-user/" + username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    .on('click', 'button.mute-user', e => {
      let username = $(e.currentTarget).parent().attr('data-username')
      e.preventDefault()
      sweetAlert({
        title: gettext.are_you_sure,
        text: gettext.the_user_wont_able_type + ' ' + ucxchat.room,
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#DD6B55",
        confirmButtonText: gettext.yes_mute_user,
        closeOnConfirm: false
      },
      function(){
        cc.put("/room/mute-user/" + username)
          .receive("ok", resp => {
            swal({
                title: gettext.muted,
                text: gettext.the_user_wont_able_type + ' ' + ucxchat.room,
                type: 'success',
                timer: 2000,
                showConfirmButton: false,
            })
          })
          .receive("error", resp => {
            toastr.error(resp.error)
          })
      });
    })
    .on('click', 'button.remove-user', e => {
      let username = $(e.currentTarget).parent().attr('data-username')
      e.preventDefault()
      sweetAlert({
        title: gettext.are_you_sure,
        text: gettext.the_user_will_be_removed_from + ' ' + ucxchat.room,
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#DD6B55",
        confirmButtonText: "Yes, remove user!",
        closeOnConfirm: false
      },
      function(){
        cc.put("/room/remove-user/" + username)
          .receive("ok", resp => {
            swal({
                title: gettext.removed,
                text: gettext.the_user_was_remove_from + ' ' + ucxchat.room,
                type: 'success',
                timer: 2000,
                showConfirmButton: false,
            })
          })
          .receive("error", resp => {
            toastr.error(resp.error)
          })
      });
    })
    .on('click', 'button.join', e => {
      cc.put("/room/join/" + ucxchat.username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    .on('click', 'a.open-room i.hide-room', e => {
      e.preventDefault()
      let room = $(e.currentTarget).closest('.open-room').data('room')
      // console.log('cliecked open-room', room)
      sweetAlert({
        title: gettext.are_you_sure,
        text: gettext.are_you_sure_you_want_to_hide_the_room + ' "' + room + '"?',
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#DD6B55",
        confirmButtonText: gettext.yes_hide_it,
        closeOnConfirm: false
      },
      function(){
        cc.put("/room/hide/" + room)
          .receive("ok", resp => {
            if (resp.redirect) {
              console.log('location')
              window.location = resp.redirect
            }
          })
          .receive("error", resp => {
            toastr.error(resp.error)
          })
      });
      return false
    })
    .on('click', 'a.open-room i.leave-room', e => {
      e.preventDefault()
      let room = $(e.currentTarget).closest('.open-room').data('room')
      sweetAlert({
        title: gettext.are_you_sure,
        text: gettext.are_you_sure_leave_the_room + ' "' + room + '"?',
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#DD6B55",
        confirmButtonText: gettext.yes_leave_it,
        closeOnConfirm: false
      },
      function(){
        cc.put("/room/leave/" + room)
          .receive("ok", resp => {
            swal({
                title: gettext.left_the_room,
                text: gettext.you_have_left_the_room + " " + ucxchat.room,
                type: 'success',
                timer: 500,
                showConfirmButton: false,
            })
          })
          .receive("error", resp => {
            toastr.error(resp.error)
          })
      });
      return false
    })
    .on('click', '.mention-link[data-channel]', (e) => {
      e.preventDefault()
      let target = $(e.currentTarget)
      let room = target.data('channel')
      this.open_room(room, room)
      return false
    })
    .on('click', 'button.jump-to', () => {
      if (debug) { console.log('jumpto', $('.first-unread').offset().top) }
      this.hide_unread_bar();
      this.unread = false
      let msgbox = $('.messages-box .wrapper')
      let valof = msgbox.scrollTop().valueOf()
      let first_top = $('.first-unread').offset().top
      let offtop = msgbox.offset().top
      let val = msgbox.scrollTop().valueOf() + $('.first-unread').offset().top - msgbox.offset().top
      if (debug) { console.log('going to scroll to', valof, first_top, offtop, val) }
      $('.messages-box .wrapper').animate({
        scrollTop: val
      }, 1000);
    })
    .on('click', 'button.mark-read', () => {
      this.remove_unread_class();
      this.hide_unread_bar();

      let mypanel = $('.messages-box .wrapper')
      let val = myPanel[0].scrollHeight - myPanel.height();
      $('.messages-box .wrapper').animate({
        scrollTop: val
      }, 1000);
      setTimeout(() => {
        this.message_box_focus()
      }, 1000)
    })
    .on('click', 'li.jump-to-message', e => {
      if (debug) { console.log('jump-to-message') }
      e.preventDefault()
      let ct = e.currentTarget
      let ts = $(ct).closest('li.message').data('timestamp')
      let target = $('.messages-box li[data-timestamp="' + ts + '"]')
      if (target.offset()) {
        scroll_to(target, -400)
      } else {
        roomHistoryManager.getSurroundingMessages(ts)
      }
      messageCog.close_cog($(ct))
      this.message_box_focus()
    })
    .on('click', '.jump-recent', e => {
      console.log('jump-recent 1')
      // messageCog.close_cog($(e.currentTarget))
      // roomHistoryManager.getRecent()
      utils.scroll_bottom()
      this.message_box_focus()
    })
    .on('click', 'button.new-message', e => {
      utils.scroll_bottom()
      this.message_box_focus()
    })
  }

  update_state(resp) {
    this.has_more = resp.has_more
    this.has_more_next = resp.has_more_next
  }

  // scroll() {
    // if (!this.isloading && this.has_more) {
    //     return
    //   } else if (utils.is_scroll_bottom()) {
    //     // console.log('reached the bottom')
    //     if (this.has_more_next) {

    //     } else {
    //        $('.jump-recent').hasClass('not')
    //     }
    //     $('.jump-recent').addClass('not')
    //   }
    // }
  //   if (this.unread) {
  //      if (debug) { console.log('scrolling unread') }
  //     if (this.is_first_unread_visible()) {
  //       if (debug) { console.log('hiding unread_bar') }

  //       if ($('.unread-bar').is(':visible')) {
  //         this.hide_unread_bar()
  //       }
  //     } else {
  //       let count = this.count_unread()
  //       if (!$('.unread-bar').is(':visible')) {
  //         $('.unread-bar').show()
  //         if (debug) { console.log('show unread bar') }
  //       } else {
  //         if (debug) { console.log('else dont show unread bar') }
  //       }
  //       $('.unread-cnt').html(count)
  //       if (debug) { console.log('count', count) }
  //     }
  //   } else {
  //      // if (debug) { console.log('scrolling no unread') }
  //   }
  // }
}

export default RoomManager;
