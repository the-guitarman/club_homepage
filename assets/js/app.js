// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from "./socket"
/*
socket.onOpen( ev => console.log("OPEN", ev) )
socket.onError( ev => console.log("ERROR", ev) )
socket.onClose( e => console.log("CLOSE", e))
*/

import MatchTimeline from "./match"
import TeamChat from "./team_chat"
import TeamChatBadge from "./team_chat_badge"
import PaymentListUpdates from "./payment_list"
import StandardTeamPlayerUpdates from "./standard_team_player"
import MatchCommitmentUpdates from "./match_commitment"

MatchTimeline.init(socket, document.getElementById("match-timeline"));
TeamChat.init(socket, $("#team-chat-input"), $('.js-team-chat #team-id[type=hidden]').val(), $('.js-team-chat #user-id[type=hidden]').val());
TeamChatBadge.init(socket, $('#team-id').val(), $('#user-id').val());
$('.js-payment-list').each(function(){
  var paymentListId = $(this).data('payment-list-id');
  PaymentListUpdates.init(socket, paymentListId);
});
$('[data-toggle=popover]').each(function(){
  var content = $(this).data('content');
  var paymentLists = $(content).find('.js-payment-list');
  paymentLists.each(function(){
    var paymentListId = $(this).data('payment-list-id');
    PaymentListUpdates.init(socket, paymentListId);
  });
});
StandardTeamPlayerUpdates.init(socket, $('.js-standard-team-players #team-id[type="hidden"]').val());
MatchCommitmentUpdates.init(socket, $('.js-match-commitments #user-id[type="hidden"]').val());
