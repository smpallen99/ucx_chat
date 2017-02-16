$(document).ready(function() {
  $('body').on('click', '.tab-button[title="Info"]', function() {
    console.log('Info button clicked...')
    if ($('section.flex-tab').parent().hasClass('opened')) {
      close_flex_tab()
    } else {
      roomchan.push("flex_bar:click:Info", {templ: "channel_settings.html", client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
        .receive("ok", resp => {
          console.log('info response', resp)
          $('section.flex-tab').html(resp.html).parent().addClass('opened')
      })
    }
  })
  $('body').on('click', '.tab-button[title="Search"]', function() {
    console.log('Search button clicked...')
  })
  $('body').on('click', '.tab-button[title="Members List"]', function() {
    console.log('Members List button clicked...')
    if ($('section.flex-tab').parent().hasClass('opened')) {
      close_flex_tab()
    } else {
      roomchan.push("flex_bar:click:Members List", {templ: "clients_list.html", client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
        .receive("ok", resp => {
          $('section.flex-tab').html(resp.html).parent().addClass('opened')
      })
    }
  })
  $('body').on('click', '.tab-button[title="User Info"]', function() {
    console.log('User Info button clicked...')
  })
  $('body').on('click', '.tab-button[title="Notifications"]', function() {
    console.log('Notifications button clicked...')
  })
  $('body').on('click', '.tab-button[title="Mentions"]', function() {
    console.log('Mentions button clicked...')
  })
  $('body').on('click', 'button.user.user-card-message', function() {
    let username = $(this).attr('data-username')
    console.log('user-card-message button clicked...', username)
    roomchan.push("flex_bar:click:Members List", {nickname: username, templ: "clients_list.html", client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
      .receive("ok", resp => {
        $('section.flex-tab').html(resp.html).parent().addClass('opened')
    })
  })
  $('body').on('click', '.tab-button[title="Logout"]', function() {
    console.log('Logout button clicked...')
    window.location.href = "/logout"
  })
  $('body').on('click', '.tab-button[title="Switch User"]', function() {
    console.log('Switch User button clicked...')
    if ($('section.flex-tab').parent().hasClass('opened')) {
      close_flex_tab()
    } else {
      console.log('Switch User button clicked opening')
      roomchan.push("flex_bar:click:Switch User", {templ: "switch_user_list.html"})
        .receive("ok", resp => {
          $('section.flex-tab').html(resp.html).parent().addClass('opened')
      })
    }
  })

  // $('body').on('click', 'li.switch_user.user-card-room button', function() {
  //   let username = $(this).attr('data-username')
  //   console.log('button.switch-user.user-card-message clicked...', username)
  //   window.location.href = "/switch_user/" + username
  // })

  $('body').on('click', '.flex-tab-container .user-view nav .button.back', function() {
    $('.flex-tab-container .user-view').addClass('animated-hidden')
  })
  $('body').on('click', 'li.user-card-room button', function() {
    console.log('li.user-card-room button clicked', $(this))
    if ($(this).parent().hasClass('switch-user')) {
      console.log('li.user-card-room button found switch user')
      let username = $(this).attr('data-username')
      console.log('button.switch-user.user-card-message clicked...', username)
      window.location.href = "/switch_user/" + username
    } else {
      console.log('li.user-card-room button found no switch user')
      let nickname = $(this).attr('data-username')
      console.log('view user button clicked', nickname)
      roomchan.push("flex_bar:click:Members List", {nickname: nickname, templ: "clients_list.html", client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
        .receive("ok", resp => {
          console.log('resp', resp)
          $('section.flex-tab').html(resp.html).parent()
          open_flex_tab()
      })
    }
  })
})

function close_flex_tab() {
  if ($('section.flex-tab').parent().hasClass('opened')) {
    $('section.flex-tab').html('').parent().removeClass('opened')
  }
}
function open_flex_tab() {
  if (!$('section.flex-tab').parent().hasClass('opened')) {
    $('section.flex-tab').parent().addClass('opened')
  }
}
