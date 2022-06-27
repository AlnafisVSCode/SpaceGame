/* SpaceGameCW
 * Author: w1727389
 * Creation date: 28/11/2021
 */

MACHINE SpaceGameCW


SETS
    GAMESTATUS = {GS};
    
    DOCKEDSTATUS = {DAS};
    
    DIRECTION = {Up, Down, Forward, Backward} ;

    REPORT = { MovedUp, MovedUp_Failed, MovedDown, MovedDown_Failed, MovedBackward, MovedBackward_Failed, 

    MovedForward, MovedForward_Failed, Initiate_Warp, INSUFFICIENT_POWER, DOCKED_AT_STARBASE, NOT_DOCKED, GAME_WON, GAME_LOST, GAME_NOT_OVER, COLLISION_ERROR }

    

CONSTANTS 

    X_axis, X_limit, 

    Y_axis, Y_limit,

    Asteroids,   
    
    Space,

    Starbase

    

PROPERTIES

    X_limit : NAT1 & X_limit = 12 

    &

    Y_limit : NAT1 & Y_limit = 7

    &

    X_axis <: NAT1 & X_axis = 1..12 

    &

    Y_axis <: NAT1 & Y_axis = 1..7 

    &

    Space : X_axis <-> Y_axis

    &

    Space = X_axis * Y_axis

    &

    Starbase <: Space & Starbase = { (6|->4)} 
    
    &
    
    Asteroids <: Space & Asteroids = {(3 |->5), (3|->2),(5 |->4),(6 |->7),(7 |->1), (7 |->5),(7 |->7),(8 |->3),(10 |->6),(11 |->2),(12 |->5)}

VARIABLES

    xx, yy, power, RegionsVisited, collisions

INVARIANT

    xx : NAT1 & xx : X_axis

    &

    yy : NAT1 & yy : Y_axis

    &

    power : NAT

    &

    collisions : NAT 
    
    &

    RegionsVisited <: Space

INITIALISATION

    xx, yy, power, collisions, RegionsVisited := 1, 1, 100,0, {}


OPERATIONS

    report <-- Move ( direction ) = 

    PRE

        direction : DIRECTION 

    THEN

        CASE direction OF EITHER

                Up THEN 

                IF ( yy < Y_limit )

                THEN

                    IF (xx |-> yy + 1 : Asteroids)

                    THEN

                        power := power - 10 ||

                        collisions := collisions + 1

                        ||

                        report := MovedUp_Failed

                    ELSIF (xx |-> yy: Starbase)

                    THEN 

                        report := GAME_WON

                    ELSIF (power < 5)

                    THEN 

                        report := GAME_LOST

                    ELSE

                        power := power - 5 || 

                        yy := yy + 1 || 

                        RegionsVisited := RegionsVisited \/ {xx |-> yy} 

                        ||

                        report := MovedUp 

                    END

                ELSE

                    report := MovedUp_Failed

                END

            OR

                Down THEN 

                IF ( yy > 1 )

                THEN

                    IF (xx |-> yy - 1 : Asteroids)

                    THEN

                        power := power - 10 ||

                        collisions := collisions + 1

                        ||

                        report := MovedDown_Failed

                    ELSIF (xx |-> yy: Starbase)

                    THEN 

                        report := GAME_WON

                    ELSIF (power < 5)

                    THEN 

                        report := GAME_LOST

                    ELSE

                        power := power - 5 ||

                        yy := yy - 1 ||

                        RegionsVisited := RegionsVisited \/ {xx |-> yy} 

                        ||

                        report := MovedDown

                    END

                ELSE

                    report := MovedDown_Failed

                END

            OR

                Backward THEN 

                IF ( xx > 1 )

                THEN

                    IF (xx - 1 |-> yy : Asteroids)

                    THEN

                        power := power - 10||

                        collisions := collisions + 1

                        ||

                        report:= MovedBackward_Failed

                    ELSIF (xx |-> yy : Starbase)

                    THEN 

                        report := GAME_WON

                    ELSIF (power < 5)

                    THEN 

                        report := GAME_LOST

                    ELSE

                        power := power - 5 ||

                        xx := xx - 1 || 

                        RegionsVisited := RegionsVisited \/ {xx |-> yy} 

                        ||

                        report := MovedBackward

                    END

                ELSE

                    report := MovedBackward_Failed

                END 

            OR

                Forward THEN 

                IF ( xx < X_limit )

                THEN

                    IF (xx + 1|-> yy : Asteroids)

                    THEN

                        power := power - 10 ||

                        collisions := collisions + 1

                        ||

                        RegionsVisited := RegionsVisited \/ {xx |-> yy} 

                        ||

                        report := MovedForward_Failed

                    ELSIF (xx |-> yy : Starbase)

                    THEN 

                        report := GAME_WON 

                    ELSIF (power < 5)

                    THEN 

                        report := GAME_LOST

                    ELSE 

                        power := power - 5 ||

                        xx := xx + 1 ||

                        RegionsVisited := RegionsVisited \/ {xx |-> yy} 

                        ||

                        report := MovedForward

                    END

                ELSE

                    report := MovedForward_Failed

                END

            END

        END

    END;


    newGame = 

    BEGIN

        xx, yy, power, RegionsVisited := 1, 1,100, {}

    END;

    xx_position, yy_position <-- position = 

    BEGIN

        xx_position, yy_position := xx, yy 

    END;

    powerReserve <-- powerReserves = 

    BEGIN

        powerReserve := power

    END;

    CollisionsCounter <-- asteroidCollisions = 

    BEGIN 

        CollisionsCounter := collisions

    END;

    report <-- DockedStatus(StatusReport) = 

    PRE

        StatusReport : DOCKEDSTATUS

    THEN

        CASE StatusReport OF EITHER

                DAS THEN 

                IF (xx |-> yy: Starbase)

                THEN 

                    report := DOCKED_AT_STARBASE

                ELSE

                    report := NOT_DOCKED

                END

            END

        END

    END;


    report <-- GameStatus(StatusOfGame) = 

    PRE

        StatusOfGame : GAMESTATUS

    THEN

        CASE StatusOfGame OF EITHER

                GS THEN 

                IF (xx |-> yy: Starbase)

                THEN 

                    report := GAME_WON

                ELSIF (power < 5)

                THEN

                    report := GAME_LOST

                ELSIF (power >= 5)

                THEN

                    report := GAME_NOT_OVER

                END

            END

        END

    END;


    report <-- warp_Drive(xxPosition, yyPosition) = 

    PRE 

        xxPosition : NAT1 & yyPosition : NAT1 &

        xxPosition : X_axis & yyPosition : Y_axis

    THEN

        IF (( yyPosition <= Y_limit ) & (xxPosition <= X_limit ) )

        THEN

            IF (xxPosition |-> yyPosition /: Asteroids  & power >= 20 )

            THEN

                xx, yy := xxPosition, yyPosition ||

                power := power - 20 

                ||

                RegionsVisited := RegionsVisited \/ {xx |-> yy} 

                ||

                report := Initiate_Warp

            ELSIF (xxPosition |-> yyPosition : Starbase)

            THEN

                report := GAME_WON

            ELSIF ( power < 20)

            THEN

                report := INSUFFICIENT_POWER

            ELSE 

                report := COLLISION_ERROR

            END

        END


    END

END