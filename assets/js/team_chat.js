let TeamChat = {
  socket: null,
  channel: null,
  teamId: 0,
  userId: 0,
  messagesList: null,
  messageInput: null,

  canInit: () => {
    return _.isNumber(TeamChat.teamId) && TeamChat.teamId > 0 &&
      _.isNumber(TeamChat.userId) && TeamChat.userId &&
      TeamChat.messagesList.length > 0 && TeamChat.messageInput.length > 0;
  },

  createTime: (at) => {
    return moment(at).format('HH:mm:ss');
  },

  createDate: (at) => {
    return moment(at).format('YYYY-MM-DD');
  },

  createNewMessagesEl: () => {
    return `<div class="js-new-messages-hint css-new-messages-hint text-center"><div>Neue Nachrichten</div></div>`;
  },

  createDateEl: (date) => {
    var format = TeamChat.messagesList.data('date-format');
    return `<div class="date text-center"><span>${moment(date).format(format)}</span></div>`;
  },

  createChatMessage: (payload) => {
    var ownMessage = payload.user_id === parseInt(TeamChat.userId) ? ' own-message' : '';
    return `<div class="message${ownMessage}" data-id="${payload.id}" data-date="${TeamChat.createDate(payload.at)}"><div class="user-name">${payload.user_name || 'Anonymous'}:</div><div>${payload.message}</div><div class="time text-right">${TeamChat.createTime(payload.at)}</div></div>`;
  },

  olderChatMessagesButtonHandler: (olderChatMessagesAvailable) => {
    var button = $('.js-show-more-chat-messages');
    if (olderChatMessagesAvailable === true) {
      button.removeProp('disabled').removeAttr('disabled').removeClass('hidden');
    } else {
      button.prop('disabled', 'disabled').attr('disabled', 'disabled').addClass('hidden');
    }
  },

  addDates: () => {
    TeamChat.messagesList.find('.date').remove();
    var currentDate = null;
    $.each(TeamChat.messagesList.find('.message'), function(index, messageEl){
      messageEl = $(messageEl);
      var date = messageEl.data('date');
      if (currentDate != date) {
        currentDate = date;
        messageEl.before(TeamChat.createDateEl(date));
      }
    });
  },

  addNewMessagesHint: (response) => {
    $('.js-new-messages-hint').remove();
    var last_read_team_chat_message_id = response.last_read_team_chat_message_id;
    if (_.isNumber(last_read_team_chat_message_id)) {
      $.each(TeamChat.messagesList.find('.message'), function(index, messageEl){
        messageEl = $(messageEl);
        var id = messageEl.data('id');
        if (id == last_read_team_chat_message_id) {
          messageEl.after(TeamChat.createNewMessagesEl());
        }
      });
    }
  },

  showNewMessagesBadge: (response) => {
    var unreadTeamChatMessagesNumber = response.unread_team_chat_messages_number;
    if (_.isNumber(unreadTeamChatMessagesNumber)) {
      $('.js-new-team-chat-messages-badge').removeClass('hidden').html(unreadTeamChatMessagesNumber);
    } else {
      TeamChat.hideNewMessagesBadge();
    }
  },

  hideNewMessagesBadge: () => {
    $('.js-new-team-chat-messages-badge').addClass('hidden').html('0');
  },

  hasMessagesHint: () => {
    return TeamChat.findLastMessagesHint().length > 0;
  },

  findLastMessagesHint: () => {
    return TeamChat.messagesList.find('.js-new-messages-hint:last');
  },

  findLastMessage: () => {
    return TeamChat.messagesList.find('.message:last');
  },

  findLastReadMessage: (messageId) => {
    return TeamChat.messagesList.find('.message[data-id=' + messageId + ']');
  },

  isMessageVisible: (message) => {
    element = TeamChat.findLastMessagesHint();
    return message.length > 0 && message.offset().top - element.offset().top < TeamChat.messagesList.outerHeight();
  },

  getMessageListScrollPositionForElement: (element) => {
    var result = TeamChat.messagesList.outerHeight();
    if (element.length > 0) {
      result = element.offset().top - TeamChat.messagesList.offset().top;
    }
    return result;
  },

  findVisibleMessageElementAtFirst: () => {
    var element = null;

    if (TeamChat.hasMessagesHint()) {
      var lastMessage = TeamChat.findLastMessage();
      if (TeamChat.isMessageVisible(lastMessage)) {
        element = lastMessage;
      } else {
        element = TeamChat.findLastMessagesHint();
      }
    }

    return element;
  },

  findMessageElementToScrollTo: (response) => {
    var element = null;

    if (_.isNumber(response.last_read_team_chat_message_id)) {
      element = TeamChat.findLastReadMessage(response.last_read_team_chat_message_id);
    }

    if (_.isEmpty(element)) {
      element = TeamChat.findVisibleMessageElementAtFirst();
    }

    if (_.isEmpty(element)) {
      element = TeamChat.findLastMessage();
    }

    return element;
  },

  scrollMessagesList: (response) => {
    var element = TeamChat.findMessageElementToScrollTo(response);
    if (!_.isEmpty(element) && element.length > 0) {
      var scrollPosition = TeamChat.getMessageListScrollPositionForElement(element);
      TeamChat.messagesList.animate({scrollTop: scrollPosition});
    }
  },

  connectAndJoin: () => {
    TeamChat.socket.connect();
    TeamChat.channel = TeamChat.socket.channel("team-chats:" + TeamChat.teamId);
    TeamChat.channel.onError(e => console.log("something went wrong", e));
    TeamChat.channel.onClose(e => console.log("channel closed", e));

    TeamChat.channel.join()
      .receive("ok", (response) => {
        $.each(response.chat_messages, function(index, chatMessage){
          TeamChat.messagesList.append(TeamChat.createChatMessage(chatMessage));
        });
        TeamChat.addDates();
        TeamChat.addNewMessagesHint(response);
        TeamChat.showNewMessagesBadge(response);
        TeamChat.olderChatMessagesButtonHandler(response.older_chat_messages_available);
        TeamChat.scrollMessagesList(response);
      })
      // .receive("error", (reason) => {
      //   console.log("join failed", reason)
      // })
      // .receive("ignore", () => {
      //   console.log("auth error")
      // })
      // .receive("timeout", () => {
      //   console.log("connection interruption")
      // })
    ;
  },

  initChannelEventAddMessage: () => {
    TeamChat.channel.on("message:added", (payload) => {
      TeamChat.messagesList.append(TeamChat.createChatMessage(payload.chat_message));
      TeamChat.addDates();
      if (TeamChat.userId != payload.current_user_id) {
        TeamChat.addNewMessagesHint(payload);
        TeamChat.showNewMessagesBadge(payload);
      }
      //TeamChat.scrollMessagesList(payload);
      TeamChat.messagesList.prop({scrollTop: TeamChat.messagesList.prop("scrollHeight")});
    });
  },

  initChannelEventShowOlderMessages: () => {
    TeamChat.channel.on("message:show-older", (payload) => {
      $.each(payload.chat_messages, function(index, chatMessage){
        TeamChat.messagesList.prepend(TeamChat.createChatMessage(chatMessage));
      });
      TeamChat.addDates();
      TeamChat.olderChatMessagesButtonHandler(payload.older_chat_messages_available);
    });
  },

  initChannelEvents: () => {
    TeamChat.initChannelEventAddMessage();
    TeamChat.initChannelEventShowOlderMessages();
  },

  initUIEvents: () => {
    $(document).on('click', $('.glyphicon.glyphicon-send').parent(), function(e) {
      var value = TeamChat.messageInput.val().trim();
      if (value.length > 0) {
        TeamChat.channel.push('message:add', {message: value});
        TeamChat.messageInput.val('');
        TeamChat.messageInput.focus();
      }
    });

    $(document).on('click', '.js-show-more-chat-messages', function(e) {
      var oldestDisplayedChatMessageId = TeamChat.messagesList.find('.message').first().data('id');
      TeamChat.channel.push('message:show-older', {id_lower_than: oldestDisplayedChatMessageId});
    });

    $(document).on('scroll', TeamChat.messagesList, function() {
      var messages = TeamChat.messagesList.find('.message');
      if (messages.length > 0 && $('.js-new-team-chat-messages-badge').hasClass('hidden') === false) {
        TeamChat.channel.push('message:seen', {message_id: messages.last().data('id')});
      }
      TeamChat.hideNewMessagesBadge();
    });
  },

  init: (socket) => {
    TeamChat.socket = socket;
    TeamChat.teamId = $('.js-team-page.js-team-chat').data('team-id');
    TeamChat.userId = $('body').data('current-user-id');
    TeamChat.messageInput = $(".js-team-page #team-chat-input");
    TeamChat.messagesList = $('.js-team-page #message-list');

    if (TeamChat.canInit()) {
      TeamChat.connectAndJoin();
      TeamChat.initChannelEvents();
      TeamChat.initUIEvents();
    }
  }
}

export default TeamChat
