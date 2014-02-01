private ["_request", "_result", "_elemsNearToProcess", "_elemsFarToProcess", "_other_units", "_xplayer"];
if !(isNull player) then {
	if ((tf_farPlayersProcessed) and {tf_nearPlayersProcessed}) then {
		tf_nearPlayersIndex = 0;
		tf_farPlayersIndex = 0;

		if (count tf_nearPlayers == 0) then {
			tf_nearPlayers = call TFAR_fnc_getNearPlayers;
		};

		tf_nearPlayers = tf_nearPlayers;
		_other_units = allUnits - tf_nearPlayers;

		tf_farPlayers = [];
		tf_farPlayersIndex = 0;	
		{
			if (isPlayer _x) then {
				tf_farPlayers set[tf_farPlayersIndex, _x];
				tf_farPlayersIndex = tf_farPlayersIndex + 1;
			};
		} count _other_units;
			
		tf_farPlayersIndex = 0;	

		if (count tf_nearPlayers > 0) then {
			tf_nearPlayersProcessed = false;
			tf_msNearPerStep = tf_msNearPerStepMax max (tf_nearUpdateTime / (count tf_nearPlayers));
			tf_msNearPerStep = tf_msNearPerStep min tf_msNearPerStepMin;
		} else {
			tf_msNearPerStep = tf_nearUpdateTime;
		};
		if (count tf_farPlayers > 0) then {
			tf_farPlayersProcessed = false;
			if (count tf_nearPlayers > 0) then {
				tf_msFarPerStep = tf_msFarPerStepMax max (tf_farUpdateTime / (count tf_farPlayers));
				tf_msFarPerStep = tf_msFarPerStep min tf_msFarPerStepMin;
			} else {
				tf_msFarPerStep = tf_msSpectatorPerStepMax;
			};
		} else {
			tf_msFarPerStep = tf_farUpdateTime;
		};
		call TFAR_fnc_sendVersionInfo;
	} else {
		_elemsNearToProcess = (diag_tickTime - tf_lastNearFrameTick) / tf_msNearPerStep;		
		if (_elemsNearToProcess >= 1) then {
			for "_y" from 0 to _elemsNearToProcess step 1 do {
				if (tf_nearPlayersIndex < count tf_nearPlayers) then {
					(tf_nearPlayers select tf_nearPlayersIndex) call TFAR_fnc_sendPlayerInfo;
					tf_nearPlayersIndex = tf_nearPlayersIndex + 1;
				} else {
					tf_nearPlayersIndex = 0;
					tf_nearPlayersProcessed = true;

					if (diag_tickTime - tf_lastNearPlayersUpdate > 0.5) then {	
						tf_nearPlayers = call TFAR_fnc_getNearPlayers;
						tf_lastNearPlayersUpdate = diag_tickTime;
					};
				};
			};
			tf_lastNearFrameTick = diag_tickTime;
		};

		_elemsFarToProcess = (diag_tickTime - tf_lastFarFrameTick) / tf_msFarPerStep;
		if (_elemsFarToProcess >= 1) then {
			for "_y" from 0 to _elemsFarToProcess step 1 do {
				if (tf_farPlayersIndex < count tf_farPlayers) then {
					(tf_farPlayers select tf_farPlayersIndex) call TFAR_fnc_sendPlayerInfo;
					tf_farPlayersIndex = tf_farPlayersIndex + 1;
				} else {
					tf_farPlayersIndex = 0;
					tf_farPlayersProcessed = true;
				};
			};
			tf_lastFarFrameTick = diag_tickTime;
		};
	};
	if (diag_tickTime - tf_lastFrequencyInfoTick > 1) then {
		call TFAR_fnc_sendFrequencyInfo;
		tf_lastFrequencyInfoTick = diag_tickTime;
	};
};