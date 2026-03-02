module CompletedEvents exposing (headerIconButton, modal, Msg(..), CompletedEvent, decode, encode)

import Html exposing (..)
import Html.Attributes exposing (..)
import Time
import Json.Decode as Decode
import Json.Encode as Encode

import Event exposing (Event, decode)
import Carbon.Icons exposing (..)
import Utils.Modal as Modal
import Utils.HeaderIconButton
import Utils.PosixTime as PosixTime

type Msg = Open | Close | NoOp

type alias CompletedEvent =
  { event: Event
  , completedAt: Time.Posix
  }

decode : Decode.Decoder CompletedEvent
decode =
  Decode.map2 CompletedEvent
    (Decode.field "event" Event.decode)
    (Decode.field "completedAt" PosixTime.decode)


encode : CompletedEvent -> Encode.Value
encode completedEvent =
    Encode.object
    [ ("event", Event.encode completedEvent.event)
    , ("completedAt", PosixTime.encode completedEvent.completedAt)
    ]

-- Icon to open the modal
headerIconButton : Html Msg
headerIconButton =
  Utils.HeaderIconButton.view "View completed" Open Carbon.Icons.taskComplete

-- Time utils for grouping completed events by day

type alias CalendarDate =
  { year: Int
  , month: Time.Month
  , day: Int
  }

viewCalendarDate : CalendarDate -> String
viewCalendarDate date =
    [ String.fromInt date.day
    , case date.month of
        Time.Jan -> "Jan"
        Time.Feb -> "Feb"
        Time.Mar -> "Mar"
        Time.Apr -> "Apr"
        Time.May -> "May"
        Time.Jun -> "Jun"
        Time.Jul -> "Jul"
        Time.Aug -> "Aug"
        Time.Sep -> "Sep"
        Time.Oct -> "Oct"
        Time.Nov -> "Nov"
        Time.Dec -> "Dec"
    , String.fromInt date.year
    ] |> String.join " "

-- TODO: Get users' time zone
posixToCalendarDate : Time.Posix -> CalendarDate
posixToCalendarDate time =
  { year = Time.toYear Time.utc time
  , month = Time.toMonth Time.utc time
  , day = Time.toDay Time.utc time
  }

isSameDay : CalendarDate -> CalendarDate -> Bool
isSameDay a b =
  a.year == b.year && a.month == b.month && a.day == b.day


-- Events completed on a specific day
type alias DaySummary =
  { date: CalendarDate
  , events: List CompletedEvent
  }

viewDaySummary : DaySummary -> Html msg
viewDaySummary daySummary =
  div []
    [ h4 [ class "my-4 text-title font-bold" ] [ text (viewCalendarDate daySummary.date) ]
    , ol [] (List.map (\e -> li [ class "my-2" ] [ text e.event.name ]) daySummary.events)
    ]

addEventToSummaries : CompletedEvent -> List DaySummary -> List DaySummary
addEventToSummaries nextEvent days =
  let
    eventDate = posixToCalendarDate nextEvent.completedAt
  in
    case days of
      [] -> [{
        date = posixToCalendarDate nextEvent.completedAt
        , events = [ nextEvent ]
        }]
      latest::rest ->
        if isSameDay latest.date eventDate then
          { date = latest.date, events = nextEvent::latest.events}::rest
        else
          {
            date = posixToCalendarDate nextEvent.completedAt
            , events = [ nextEvent ]
          }::rest


-- Input to the modal
type alias Model a =
  { a
  | completedModalOpen: Bool
  , completedEvents: List CompletedEvent
  }

-- The modal itself
modal : Model a -> Html Msg
modal { completedModalOpen, completedEvents } =
  Modal.view completedModalOpen Close NoOp
    [ h2 [ class "font-bold text-title mb-4" ] [ text "Completed events" ]
    , if List.length completedEvents > 0 then
        ul [] (
          completedEvents
          |> List.sortWith (\a b ->
              compare
                (Time.posixToMillis b.completedAt)
                (Time.posixToMillis a.completedAt)
            )
          |> List.foldr addEventToSummaries []
          |> List.map viewDaySummary
        )
      else
        p [] [ text "Mark events as completed and they'll show up here" ]
    ]
