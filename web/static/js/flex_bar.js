$(document).ready(function() {
  $('body').on('click', '.tab-button[title="Info"]', function() {
    console.log('Info button clicked...')
    if ($('section.flex-tab').parent().hasClass('opened')) {
      $('section.flex-tab').html('').parent().removeClass('opened')
    } else {
      ucxchat.chan.push("flex_bar:click:Info", {templ: "channel_settings.html", client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
        .receive("ok", resp => {
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
      $('section.flex-tab').html('').parent().removeClass('opened')
    } else {
      ucxchat.chan.push("flex_bar:click:Members List", {templ: "clients_list.html", client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
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
    ucxchat.chan.push("flex_bar:click:Members List", {nickname: username, templ: "clients_list.html", client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
      .receive("ok", resp => {
        if (!$('section.flex-tab').parent().hasClass('opened')) {
          $('section.flex-tab').html(resp.html).parent().addClass('opened')
        }
    })
  })
})
