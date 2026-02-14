port module Main exposing (..)

import Browser
import Browser.Events
import Browser.Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Time
import Platform.Cmd as Cmd

import Event exposing (..)
import EventCreator exposing (..)
import Key exposing (keyDecoder)
import Task

-- MAIN PROGRAM MODELLING

main : Program () Model Msg
main =
  Browser.element
    { init = init
    , view = view
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
type PortMsg
  = UuidAndTime { uuid: String, time: Int }
  | KeyPress Key.Key

subscriptions : Model -> Sub PortMsg
subscriptions _ = Sub.batch
  [ uuidAndTime UuidAndTime
  , keyDecoder |> Browser.Events.onKeyDown >> Sub.map KeyPress
  ]

port getNewEventData : () -> Cmd msg
port uuidAndTime : ({ uuid: String, time: Int } -> msg) -> Sub msg

type Msg
  = Port PortMsg
  | EventCreatorMsg EventCreator.Msg
  | EventButtonMsg Event.Msg
  | NoOp

-- UPDATE

nextItem : Model -> Model
nextItem model = case model.events of
  first::tail -> { model | events = tail ++ [first] }
  _ -> model

bumpToTop : Model -> String -> Model
bumpToTop model id =
  let
   newEvents = model.events
     |> List.partition (\e -> e.id == id)
     |> (\a -> [Tuple.first a, Tuple.second a])
     |> List.concat
  in
    { model | events = newEvents }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp -> (model, Cmd.none)
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
      KeyPress key ->
        case model.mode of
          Drafting -> (model, Cmd.none)
          ViewEvents ->
            case key of
              Key.Spacebar -> (nextItem model, Cmd.none)
              Key.N -> ({ model | mode = Drafting }, Cmd.none)
              Key.B ->
                let
                  newEvents = case model.events of
                      first::rest -> { first | isBlocked = not first.isBlocked }::rest
                      _ -> model.events
                in
                  ({ model | events = newEvents  }, Cmd.none)
              Key.D ->
                let
                  newEvents = case model.events of
                      _::rest -> rest
                      _ -> model.events
                in
                  ({ model | events = newEvents  }, Cmd.none)
              _ -> (model, Cmd.none)
    EventCreatorMsg creatorMsg -> case creatorMsg of
      EventCreator.UpdateDraft newDraft ->
            ({ model | draft = newDraft }, Cmd.none)
      EventCreator.CreateEvent draft ->
        let
          trimmedDraft = { draft | name = String.trim draft.name }
        in case trimmedDraft.name of
          "" -> (model, Cmd.none)
          _ -> (
            { model | mode = ViewEvents, draft = EventCreator.emptyDraft, submittedDraft = Just trimmedDraft }
            , getNewEventData ()
            )
      EventCreator.Expand -> (
        { model | mode = Drafting }
        , Task.attempt (\_ -> NoOp) (Browser.Dom.focus EventCreator.textInputId)
        )
      EventCreator.Hide -> ({ model | mode = ViewEvents }, Cmd.none)
    EventButtonMsg buttonMsg -> case buttonMsg of
      Event.NextItem -> (nextItem model, Cmd.none)
      Event.BumpToTop id -> (bumpToTop model id, Cmd.none)
      Event.Delete id ->
        ({ model | events = List.filter (\e -> not (e.id == id)) model.events }, Cmd.none)
      Event.ToggleBlocked id ->
        let
          newEvents = List.map
            (\e -> if e.id == id then { e | isBlocked = not e.isBlocked } else e)
            model.events
        in
          ({ model | events = newEvents }, Cmd.none)

-- VIEW

view : Model -> Html Msg
view model = div []
  [  header []
    [ h1 [ class "max-w-4xl px-16 mx-auto py-8 text-bold flex justify-between" ]
      [ text "Event loop"
      , img [ src "/event-loop/static/favicon.svg", class "inline h-[1.5lh] mr-2 pb-1" ] []
      ]
    ]
  , div [ class "max-w-4xl px-16 mx-auto" ]
    [ EventCreator.view (model.mode == Drafting) model.draft |> Html.map EventCreatorMsg
    , Event.view model.events |> Html.map EventButtonMsg
    ]
  ]
