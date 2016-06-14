$(document).ready(function() {
	var translations = {
		en: {
			"kick-off" 				  : "Kick-Off", 
			"half-time-break" 		  : "Half-Time-Break",
			"final-whistle" 		  : "Final-Whistle",
			"break" 				  : "Break",
			"continuation" 			  : "Continuation",
			"quit"	 				  : "Quit",
			"goal" 					  : "Goal",
			"penalty" 				  : "Penalty Goal",
			"replacement" 			  : "Replacement",
			"penalty-shoot-out" 	  : "Penalty-Shoot-Out",
			"penalty-goal" 			  : "Goal",
			"no-penalty-goal" 		  : "No Goal",
			"foul-yellow" 			  : "Yellow Card",
			"foul-yellow-red" 		  : "Yellow-Red Card",
			"foul-red" 				  : "Red Card",
			"match-score" 			  : "Match Score",
			"final-score" 			  : "Final Score",
			"delete-latest-element"   : "Delete Latest Element",

			"for-example-abbr"		  : ["e.g.", "for example"],
			"weather" 				  : "Weather",
			"o_clock"				  : "",

			"input-minute"			  : "Minute",
			"input-event"			  : "Event",
			"input-text"			  : "Player (Number) / Text",
			"input-own-goal"		  : "Own Goal",
			"input-out"				  : "Player Out",
			"input-in"				  : "Player In",

			"own-goal-abbr"			  : "Own Goal",
			"after-extra-time-abbr"   : "AET",
			"after-penalty-shoot-out" : "APS"

		},

		de: {
			"kick-off" 				  : "Anstoß", 
			"half-time-break" 		  : "Halbzeitpause",
			"final-whistle" 		  : "Abpfiff",
			"break" 				  : "Unterbrechung",
			"continuation" 			  : "Weiter",
			"quit"	 				  : "Abbruch",
			"goal" 					  : "Tor",
			"penalty" 				  : "Elfmetertor",
			"replacement" 			  : "Auswechslung",
			"penalty-shoot-out" 	  : "Elfmeterschießen",
			"penalty-goal" 			  : "Tor",
			"no-penalty-goal" 		  : "kein Tor",
			"foul-yellow" 			  : "Gelbe Karte",
			"foul-yellow-red" 		  : "Gelb-Rote Karte",
			"foul-red" 				  : "Rote Karte",
			"match-score" 			  : "Spielstand",
			"final-score" 			  : "Endstand",
			"delete-latest-element"   : "Letztes Ereignis löschen",

			"for-example-abbr"		  : ["z. B.", "zum Beispiel"],
			"weather" 				  : "Wetter",
			"o_clock"				  : "Uhr",

			"input-minute"			  : "Minute",
			"input-event"			  : "Ereignis",
			"input-text"			  : "Spielename / Text",
			"input-own-goal"		  : "Eigentor",
			"input-out"				  : "Auswechslung",
			"input-in"				  : "Einwechslung",

			"own-goal-abbr"			  : "ET",
			"after-extra-time-abbr"   : "n.V.",
			"after-penalty-shoot-out" : "n.E."
		}	
	};

	var matchTimeline = $('#match-timeline');
	if (matchTimeline.length > 0) {
		var language = matchTimeline.data('language');
		var data = translations[language];
	    if (_.isEmpty(data)) {
  			moment.locale('en');
	    	data = translations['en'];
	    } else {
  			moment.locale(language);
	    }
	    matchTimeline.data('translations', data);
	}
});