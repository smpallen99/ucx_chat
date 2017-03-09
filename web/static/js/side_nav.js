import toastr from 'toastr'
import * as cc from './chat_channel'
import RoomManager from './room_manager'

class SideNav {
  constructor() {
    this.register_events()
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

  register_events() {
    $('body')
    .on('click', 'span.arrow.close', (e) => {
      e.preventDefault()
      $('.flex-nav header').click()
    })
    .on('click', 'span.arrow', (e) => {
      e.preventDefault()
      $('.side-nav .account-box').click()
    })
    .on('click', '.side-nav .account-box', (e) => {
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
    .on('click', 'button#logout', (e) => {
      e.preventDefault()
      window.location.href = "/logout"
    })
    .on('click', 'button.account-link', (e) => {
      e.preventDefault()
      $('.main-content-cache').html($('.main-content').html())
      userchan.push('side_nav:open', {page: $(e.currentTarget).attr('id')})
        .receive("ok", resp => {
          $('.flex-nav section').html(resp.html)
        })
      $('div.flex-nav').removeClass('animated-hidden')
      $('aside.side-nav span.arrow').removeClass('top').addClass('close')
    })
    .on('click', 'nav.options button.status', (e) =>  {
      e.preventDefault()
      systemchan.push('status:set:' + $(e.currentTarget).data('status'), {})
    })
    .on('click', '.flex-nav header', (e) => {
      e.preventDefault()
      userchan.push('side_nav:close', {})
      console.log('.flex-nav header clicked')
      $('div.flex-nav').addClass('animated-hidden')
      $('aside.side-nav span.arrow').removeClass('close').addClass('bottom')
      $('.main-content').html($('.main-content-cache').html())
      $('.main-content-cache').html('')
      SideNav.hide_account_box_menu()
    })
    .on('click', '.account-link', e => {
      e.preventDefault()
      userchan.push('account_link:click:' + $(e.currentTarget).data('link'), {})
    })
    .on('click', '.admin-link', e => {
      e.preventDefault()
      userchan.push('admin_link:click:' + $(e.currentTarget).data('link'), {})
    })
    .on('submit', '#account-preferences-form', e => {
      e.preventDefault()
      userchan.push('account:preferences:save', $(e.currentTarget).serializeArray())
        .receive("ok", resp => {
          if (resp.success) {
            toastr.success(resp.success)
          } else if (resp.error) {
            toastr.error(resp.error)
          }
        })
    })
    .on('click', 'button.more-channels', e =>  {
      e.preventDefault()
      this.more_channels()
      return false
    })
    .on('click', 'a.channel-link', e => {
      e.preventDefault()
      this.channel_link_click($(e.currentTarget))
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
