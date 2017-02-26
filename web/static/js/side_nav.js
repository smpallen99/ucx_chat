import toastr from 'toastr'

class SideNav {
  constructor() {
    this.register_events()
  }
  register_events() {
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
      clientchan.push('side_nav:open', {page: $(this).attr('id')})
        .receive("ok", resp => {
          $('.flex-nav section').html(resp.html)
        })
      $('div.flex-nav').removeClass('animated-hidden')
      $('aside.side-nav span.arrow').removeClass('top').addClass('close')
    })
    // $('button#admin').on('click', function(e) {
    //   console.log('clicked admin....')
    //   e.preventDefault()
    //   $('.main-content-cache').html($('.main-content').html())
    //   clientchan.push('side_nav:open', {page: "admin"})
    //     .receive("ok", resp => {
    //       $('.flex-nav section').html(resp.html)
    //     })
    //   $('div.flex-nav').removeClass('animated-hidden')
    //   $('aside.side-nav span.arrow').removeClass('top').addClass('close')
    // })
    $('nav.options button.status').on('click', function(e) {
      e.preventDefault()
      clientchan.push('status:set:' + $(this).data('status'), {})
    })
    $('body').on('click', '.flex-nav header', function(e) {
      e.preventDefault()
      clientchan.push('side_nav:close', {})
      console.log('.flex-nav header clicked')
      $('div.flex-nav').addClass('animated-hidden')
      $('aside.side-nav span.arrow').removeClass('close').addClass('bottom')
      $('.main-content').html($('.main-content-cache').html())
      $('.main-content-cache').html('')
      SideNav.hide_account_box_menu()
    })
    $('body').on('click', '.account-link', function(e) {
      e.preventDefault()
      clientchan.push('account_link:click:' + $(this).data('link'), {})
        // .receive("ok", resp => {
        //   $('.main-content').html(resp.html)
        // })
    })
    $('body').on('submit', '#account-preferences-form', function(e) {
      e.preventDefault()
      // console.log('submitted form', $(this).serializeArray())
      clientchan.push('account:preferences:save', $(this).serializeArray())
        .receive("ok", resp => {
          if (resp.success) {
            toastr.success(resp.success)
          } else if (resp.error) {
            toastr.error(resp.error)
          }
        })
    })
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
