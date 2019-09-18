import $ from 'jquery';
window.$ = window.jQuery = window.jquery = $;

//require('../vendor/js/01_02_jquery-ui-1.12.1.custom.min.js');
// import 'jquery-ui/themes/base/core.css';
// import 'jquery-ui/themes/base/theme.css';
// import 'jquery-ui/themes/base/selectable.css';
// import 'jquery-ui/ui/core';
// import 'jquery-ui/ui/widgets/selectable';
//import 'jquery-ui';

import _ from 'underscore';
window._ = window.underscore = _;

import * as moment from 'moment';
import 'moment/locale/de';
window.m = window.moment = moment;

import 'bootstrap';
//import 'bootstrap/dist/css/bootstrap.css';
//require('../vendor/js/02_bootstrap.min.js');

require('../vendor/js/05_bootstrap-datetimepicker.js');

import 'select2';
//require('../vendor/js/06_select2.js');

require('../vendor/js/07_bootstrap-switch.min.js');
require('../vendor/js/08_medium-editor.min.js');
require('../vendor/js/09_bootstrap-tooltip.js');
require('../vendor/js/15_leaflet_routing_maschine_highlight.pack.js');
require('../vendor/js/16_leaflet_0.7.7.js');
require('../vendor/js/17_leaflet_iconlabel.js');
require('../vendor/js/18_control_geocoder.js');
require('../vendor/js/19_leaflet_routing_maschine.js');
require('../vendor/js/20_open_street_map.js');
require('../vendor/js/35_player_planning.js');
require('../vendor/js/99_jquery_ready.js');

//import "./../css/app.less"

// import font_eot from '../static/fonts/glyphicons-halflings-regular.eot';
// import font_svg from '../static/fonts/glyphicons-halflings-regular.svg';
// import font_ttf from '../static/fonts/glyphicons-halflings-regular.ttf';
// import font_woff from '../static/fonts/glyphicons-halflings-regular.woff';
// import font_woff2 from '../static/fonts/glyphicons-halflings-regular.woff2';

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

import MatchTimelineConstants from "./match_timeline.constants";
import matchStateMethods from './match_timeline.match_state_methods';
import buttonTextTranslator from './match_timeline.button_text_translator';

import MatchTimeline from "./match_timeline"
import TeamChat from "./team_chat"
import TeamChatBadge from "./team_chat_badge"
import PaymentListUpdates from "./payment_list"
import StandardTeamPlayerUpdates from "./standard_team_player"
import MatchCommitmentUpdates from "./match_commitment"

MatchTimeline.init(socket);
TeamChat.init(socket);
TeamChatBadge.init(socket);
PaymentListUpdates.init(socket);
StandardTeamPlayerUpdates.init(socket);
MatchCommitmentUpdates.init(socket);
