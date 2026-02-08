port module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Time

import Event exposing (..)
import EventCreator exposing (..)
import Platform.Cmd as Cmd

-- MAIN PROGRAM MODELLING

main : Program () Model Msg
main =
  Browser.element
    { init = init
    , view = view >> Html.map User
    , update = update
    , subscriptions = subscriptions >> Sub.map Port
    }

type AppMode
  = Drafting
  | ViewEvents

type alias Model =
  { mode: AppMode
  , draft: EventCreator.DraftEvent
  , submittedDraft: Maybe EventCreator.DraftEvent
  , events: List Event
  }

init : () -> ( Model, Cmd Msg )
init _ = (
  { mode = Drafting
  , draft = EventCreator.emptyDraft
  , submittedDraft = Nothing
  , events = []
  }
  , Cmd.none
  )

-- PORTS AND SUBSCRIPTIONS

subscriptions : Model -> Sub PortMsg
subscriptions _ =
  uuidAndTime UuidAndTime

port getNewEventData : () -> Cmd msg
port uuidAndTime : ({ uuid: String, time: Int } -> msg) -> Sub msg

type PortMsg = UuidAndTime { uuid: String, time: Int }

type Msg
  = Port PortMsg
  | User EventCreator.Msg

-- UPDATE

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
      EventCreator.UpdateDraft newDraft ->
        ({ model | draft = newDraft }, Cmd.none)
      EventCreator.CreateEvent draft -> (
        { model | mode = ViewEvents, draft = EventCreator.emptyDraft, submittedDraft = Just draft }
        , getNewEventData ()
        )
      EventCreator.Expand -> ({ model | mode = Drafting }, Cmd.none)
      EventCreator.Hide -> ({ model | mode = ViewEvents }, Cmd.none)

-- VIEW

view : Model -> Html EventCreator.Msg
view model = div [] ([
  h1 [] [ text "Event loop" ]
  , EventCreator.view (model.mode == Drafting) model.draft
  ] ++ (model.events |> List.map Event.view)
  )
