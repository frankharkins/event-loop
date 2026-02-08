port module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Time

import Event exposing (..)
import EventCreator exposing (..)

main : Program () Model Msg
main =
  Browser.element
    { init = init
    , view = view >> Html.map User
    , update = update
    , subscriptions = subscriptions >> Sub.map Port
    }

type alias Model =
  { draft: EventCreator.DraftEvent
  , submittedDraft: Maybe EventCreator.DraftEvent
  , events: List Event
  }

init : () -> ( Model, Cmd Msg )
init _ = (
  { draft = EventCreator.emptyDraft
  , submittedDraft = Nothing
  , events = []
  }
  , Cmd.none
  )

port getNewEventData : () -> Cmd msg
port uuidAndTime : ({ uuid: String, time: Int } -> msg) -> Sub msg

type PortMsg = UuidAndTime { uuid: String, time: Int }

type Msg
  = Port PortMsg
  | User EventCreator.Msg

update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
  case msg of
    Port portmsg -> case portmsg of
      UuidAndTime { uuid, time } ->
        case model.submittedDraft of
          Just submitted ->
            let
              newEvent =
                { name = submitted.name
                , isBlocked = submitted.isBlocked
                , createdAt = Time.millisToPosix time
                , id = uuid
                }
            in
              ({ model | submittedDraft = Nothing, events = (newEvent :: model.events) }
              , Cmd.none
              )
          Nothing -> (model, Cmd.none)
    User usrmsg -> case usrmsg of
      EventCreator.UpdateDraft newDraft -> ({ model | draft = newDraft }, Cmd.none)
      EventCreator.CreateEvent draft -> (
        { model | draft = emptyDraft, submittedDraft = Just draft }
        , getNewEventData ()
        )


-- SUBSCRIPTIONS

subscriptions : Model -> Sub PortMsg
subscriptions _ =
  uuidAndTime UuidAndTime

-- VIEW

view : Model -> Html EventCreator.Msg
view model = div [] ([
  h1 [] [ text "Event loop" ]
  , EventCreator.view model.draft
  ] ++ (model.events |> List.map Event.view)
  )
