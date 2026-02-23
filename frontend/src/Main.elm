port module Main exposing (..)

import Browser
import Browser.Events
import Browser.Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Time
import Task
import Platform.Cmd as Cmd

import Event exposing (..)
import Modal exposing (..)
import EventCreator exposing (..)
import Key exposing (keyDecoder)
import LocalStorage exposing (..)
import Process

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
  , unsavedChanges: Int
  , modalOpen: Bool
  }

init : () -> ( Model, Cmd Msg )
init _ = (
  { mode = ViewEvents
  , draft = EventCreator.emptyDraft
  , submittedDraft = Nothing
  , events = []
  , unsavedChanges = 0
  , modalOpen = False
  }
  , requestLocalStorage "events"
  )

-- PORTS AND SUBSCRIPTIONS
type PortMsg
  = UuidAndTime { uuid: String, time: Int }
  | KeyPress Key.Key
  | ReadLocalStorage LocalStorageValue

subscriptions : Model -> Sub PortMsg
subscriptions _ = Sub.batch
  [ uuidAndTime UuidAndTime
  , keyDecoder |> Browser.Events.onKeyDown >> Sub.map KeyPress
  , readLocalStorage ReadLocalStorage
  ]

-- To create a new event, we request the time and a UUID from JS through the
-- getNewEventData port. JS sends that information to the uuidAndTimePort.
port getNewEventData : () -> Cmd msg
port uuidAndTime : ({ uuid: String, time: Int } -> msg) -> Sub msg
-- We write key/value pairs to local storage. We can also request a key and the
-- pair will be sent to the readLocalStorage port.
port writeLocalStorage : LocalStorageValue -> Cmd msg
port requestLocalStorage : String -> Cmd msg
port readLocalStorage : (LocalStorageValue -> msg) -> Sub msg

type Msg
  = Port PortMsg
  | EventCreatorMsg EventCreator.Msg
  | ModalMsg Modal.Msg
  | EventButtonMsg Event.Msg
  | AttemptSave Int
  | NoOp

requestSave : Model -> (Model, Cmd Msg)
requestSave model =
  ({ model | unsavedChanges = model.unsavedChanges + 1 }
  , Process.sleep 500
    |> Task.perform (\_ -> AttemptSave (model.unsavedChanges + 1))
  )

focusDraftInput : Cmd Msg
focusDraftInput = Task.attempt (\_ -> NoOp) (Browser.Dom.focus EventCreator.textInputId)

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
    AttemptSave unsavedChanges ->
      if unsavedChanges >= model.unsavedChanges then
        ({ model | unsavedChanges = 0 }
        , writeLocalStorage { key = "events", value = encodeEventList model.events }
        )
      else
        (model, Cmd.none)
    Port portmsg -> case portmsg of
      ReadLocalStorage { key, value } ->
        case key of
          "events" -> case (value |> decodeLocalStorage eventListDecoder) of
            Ok (Just events) -> ({ model | events = events }, Cmd.none)
            _ -> (model, Cmd.none)
          _ -> (model, Cmd.none)
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
              events = newEvent :: model.events
            in
              requestSave { model | submittedDraft = Nothing, events = events }
          Nothing -> (model, Cmd.none)
      KeyPress key ->
        case model.mode of
          Drafting -> (model, Cmd.none)
          ViewEvents ->
            case key of
              Key.Spacebar -> nextItem model |> requestSave
              Key.N -> ({ model | mode = Drafting }, focusDraftInput)
              Key.H -> ({ model | modalOpen = not model.modalOpen }, Cmd.none)
              Key.Escape -> ({ model | modalOpen = False, mode = ViewEvents }, Cmd.none)
              Key.B ->
                let
                  newEvents = case model.events of
                      first::rest -> { first | isBlocked = not first.isBlocked }::rest
                      _ -> model.events
                in
                  requestSave { model | events = newEvents  }
              Key.D ->
                let
                  newEvents = case model.events of
                      _::rest -> rest
                      _ -> model.events
                in
                  requestSave { model | events = newEvents  }
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
        , focusDraftInput
        )
      EventCreator.Hide -> ({ model | mode = ViewEvents }, Cmd.none)
    EventButtonMsg buttonMsg -> case buttonMsg of
      Event.NextItem -> nextItem model |> requestSave
      Event.BumpToTop id -> bumpToTop model id |> requestSave
      Event.Delete id ->
        requestSave { model | events = List.filter (\e -> not (e.id == id)) model.events }
      Event.ToggleBlocked id ->
        let
          newEvents = List.map
            (\e -> if e.id == id then { e | isBlocked = not e.isBlocked } else e)
            model.events
        in
          requestSave { model | events = newEvents }
    ModalMsg ToggleOpen ->
      ({ model | modalOpen = not model.modalOpen }, Cmd.none)

-- VIEW

view : Model -> Html Msg
view model = div []
  [ Modal.modal model.modalOpen |> Html.map ModalMsg
  , header []
    [ h1 [ class "max-w-4xl px-8 sm:px-16 mx-auto py-8 text-bold flex justify-between" ]
      [ div [ class "flex justify-between" ]
        [ img [ src "/event-loop/static/favicon.svg", class "inline h-[1.5lh] mr-2 pb-2" ] []
        , h1 [] [ text "Event loop" ]
        ]
      , Modal.viewIcon |> Html.map ModalMsg
      ]
    ]
  , div [ class "max-w-4xl px-8 sm:px-16 mx-auto" ]
    [ EventCreator.view (model.mode == Drafting) model.draft |> Html.map EventCreatorMsg
    , Event.view model.events |> Html.map EventButtonMsg
    ]
  ]
