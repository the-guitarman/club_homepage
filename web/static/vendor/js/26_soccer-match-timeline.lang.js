$(document).ready(function() {
	var translations = {
		en: {
			"kick-off" 				: "Kick-Off", 
			"half-time-break" 		: "Half-Time-Break",
			"final-whistle" 		: "Final-Whistle",
			"break" 				: "Break",
			"continuation" 			: "Continuation",
			"goal" 					: "Goal",
			"penalty" 				: "Penalty Goal",
			"replacement" 			: "Replacement",
			"penalty-shoot-out" 	: "Penalty-Shoot-Out",
			"penalty-goal" 			: "Goal",
			"no-penalty-goal" 		: "No Goal",
			"foul-yellow" 			: "Yellow Card",
			"foul-yellow-red" 		: "Yellow-Red Card",
			"foul-red" 				: "Red Card",
			"match-score" 			: "Match Score",
			"final-score" 			: "Final Score",
			"delete-latest-element" : "Delete Latest Element",
			"for-example-abbr"		: ["e.g.", "for example"],
			"weather" 				: "Weather"
		},

		de: {
			"kick-off" 				: "Anstoß", 
			"half-time-break" 		: "Halbzeitpause",
			"final-whistle" 		: "Abpfiff",
			"break" 				: "Unterbrechung",
			"continuation" 			: "Weiter",
			"goal" 					: "Tor",
			"penalty" 				: "Elfmetertor",
			"replacement" 			: "Auswechslung",
			"penalty-shoot-out" 	: "Elfmeterschießen",
			"penalty-goal" 			: "Tor",
			"no-penalty-goal" 		: "kein Tor",
			"foul-yellow" 			: "Gelbe Karte",
			"foul-yellow-red" 		: "Gelb-Rote Karte",
			"foul-red" 				: "Rote Karte",
			"match-score" 			: "Spielstand",
			"final-score" 			: "Endstand",
			"delete-latest-element" : "Letztes Ereignis löschen",
			"for-example-abbr"		: ["z. B.", "zum Beispiel"],
			"weather" 				: "Wetter"
		}	
	};

	var matchTimeline = $('#match-timeline');
	if (matchTimeline.length > 0) {
		var language = matchTimeline.data('language');
		var data = translations[language];
	    if (_.isEmpty(data)) {
	    	data = translations['en'];
	    }
	    matchTimeline.data('translations', data);
	}
});