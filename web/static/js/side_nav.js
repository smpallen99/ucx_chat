import toastr from 'toastr'
import * as cc from './chat_channel'
import RoomManager from './room_manager'

class SideNav {
  constructor() {
    this.register_events(this)
  }

  more_channels() {
    console.log('cliecked more channels')
    userchan.push('side_nav:more_channels')
      .receive("ok", resp => {
         $('.flex-nav section').html(resp.html).parent().removeClass('animated-hidden')
         $('.arrow').toggleClass('close', 'bottom')
      })
  }
  channel_link_click(elem) {
    let name = elem.attr('href').replace('/channels/', '')
    console.log('channel link click', name)
    RoomManager.open_room(name, name, function() {
      $('.flex-nav').addClass('animated-hidden')
      $('.arrow').toggleClass('close', 'bottom')
    })
  }

  register_events(_this) {
    $('body').on('click', 'span.arrow.close', function(e) {
      e.preventDefault()
      $('.flex-nav header').click()
    })
    $('span.arrow').on('click', function(e) {
      e.preventDefault()
      $('.side-nav .account-box').click()
    })
    // $('aside.side-nav > span.arrow').on('click', function() {
    $('.side-nav .account-box').on('click', function(e) {
      e.preventDefault()
      let elem = $('aside.side-nav span.arrow')
      if (elem.hasClass('top')) {
        elem.removeClass('top').addClass('bottom')
        SideNav.hide_account_box_menu()
      } else {
        elem.addClass('top').removeClass('bottom')
        SideNav.show_account_box_menu()
      }
    })

    $('button#logout').on('click', function(e) {
      e.preventDefault()
      window.location.href = "/logout"
    })
    $('button.account-link').on('click', function(e) {
      e.preventDefault()
      $('.main-content-cache').html($('.main-content').html())
      userchan.push('side_nav:open', {page: $(this).attr('id')})
        .receive("ok", resp => {
          $('.flex-nav section').html(resp.html)
        })
      $('div.flex-nav').removeClass('animated-hidden')
      $('aside.side-nav span.arrow').removeClass('top').addClass('close')
    })
    $('nav.options button.status').on('click', function(e) {
      e.preventDefault()
      systemchan.push('status:set:' + $(this).data('status'), {})
    })
    $('body').on('click', '.flex-nav header', function(e) {
      e.preventDefault()
      userchan.push('side_nav:close', {})
      console.log('.flex-nav header clicked')
      $('div.flex-nav').addClass('animated-hidden')
      $('aside.side-nav span.arrow').removeClass('close').addClass('bottom')
      $('.main-content').html($('.main-content-cache').html())
      $('.main-content-cache').html('')
      SideNav.hide_account_box_menu()
    })
    $('body').on('click', '.account-link', function(e) {
      e.preventDefault()
      userchan.push('account_link:click:' + $(this).data('link'), {})
    })
    $('body').on('click', '.admin-link', function(e) {
      e.preventDefault()
      userchan.push('admin_link:click:' + $(this).data('link'), {})
    })
    $('body').on('submit', '#account-preferences-form', function(e) {
      e.preventDefault()
      userchan.push('account:preferences:save', $(this).serializeArray())
        .receive("ok", resp => {
          if (resp.success) {
            toastr.success(resp.success)
          } else if (resp.error) {
            toastr.error(resp.error)
          }
        })
    })
    $('body').on('click', 'button.more-channels', function(e) {
      e.preventDefault()
      _this.more_channels()
      return false
    })
    $('body').on('click', 'a.channel-link', function(e) {
      e.preventDefault()
      _this.channel_link_click($(this))
      return false
    })
    // $('button.status').on('click', function(e) {
    //   console.log('clicked status change', $(this).data('status'))
    // })
  }
  static show_account_box_menu() {
    console.log('show_account_box_menu')
    $('.account-box').addClass('active')
    $('.account-box nav.options').removeClass('animated-hidden')
  }

  static hide_account_box_menu() {
    console.log('hide_account_box_menu')
    $('.account-box').removeClass('active')
    $('.account-box nav.options').addClass('animated-hidden')
  }
}

export default SideNav;
