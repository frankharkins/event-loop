module Model exposing (Model, AppMode(..), default, decodePersistent, serializePersistent)

import Json.Decode as Decode

import Event exposing (Event, encode, decode)
import EventCreator
import CompletedEvents
import Json.Encode as Encode

type alias Model =
  -- Not persisted (memory only)
  { mode: AppMode
  , draft: EventCreator.DraftEvent
  , submittedDraft: Maybe EventCreator.DraftEvent
  , unsavedChanges: Int
  , helpModelOpen: Bool
  , completedModalOpen: Bool
  , pendingCompletedEvents: List Event
  -- Persisted through local storage
  , events: List Event
  , completedEvents: List CompletedEvents.CompletedEvent
  }

default : Model
default =
  { mode = ViewEvents
  , draft = EventCreator.emptyDraft
  , submittedDraft = Nothing
  , unsavedChanges = 0
  , helpModelOpen = False
  , completedModalOpen = False
  , pendingCompletedEvents = []
  , events = []
  , completedEvents = []
  }

type AppMode
  = Drafting
  | ViewEvents


-- State that should be saved
type alias PersistentState =
  { events: List Event
  , completedEvents: List CompletedEvents.CompletedEvent
  }

decodePersistent : Decode.Decoder PersistentState
decodePersistent =
  Decode.map2 PersistentState
    (Decode.field "events" (Decode.list Event.decode))
    (Decode.field "completedEvents" (Decode.list CompletedEvents.decode))

serializePersistent : Model -> String
serializePersistent model =
  Encode.object
    [ ("events", model.events |> Encode.list Event.encode)
    , ("completedEvents", model.completedEvents
          |> Encode.list CompletedEvents.encode
      )
    ]
  |> Encode.encode 0
