## Visual Editing ##

In order to start visual editing (visual creation of a zone), one must
execute the szaddzone ULX command.

A net messsage will be sent to the player signalling to display the
visual editing UI. At this point, all editing is done clientside.

When editing is finished, RunConsoleCommand executes the ULX command
szrawcreatezone with the coordinates passed in. This is the actual
command that creates the zone serverside.

The editing happens in 3 stages: Stage 0, 1, and 2.

In stage 0, we are waiting for the player to mark the top left corner of the zone.
In stage 1, we are waiting for the player to mark the bottom right corner of the zone.
In stage 2, the zone is created. No interaction happens in this zone, so it would be
logical to say that it doesn't exist.

Marking is done by typing `!szmark` in chat. This is not a ULX command and is handled
entirely clientside.

## Viewing all zones ##

Zones are not rendered by default clientside. They can be rendered clientside by issuing
the szviewallon ULX command. Viewing is disabled via the szviewalloff ULX command.

Because zones are stored entirely serverside, they are sent to clients upon `!szviewallon`
invocation.

Zones are also sent to clients sometimes. See `SZ.Zone.Rebroadcast` and `SZ.Zone.SendAll`
usages.
