module Main exposing (main)

import Html exposing (..)
import Context exposing (Context)
import MainMenu


type alias Model =
    { context : Context
    , pageModels : PageModels
    }


type Msg
    = ContextMsg Context.Msg
    | MainMenuMsg MainMenu.Msg


type alias PageModels =
    { mainMenu : MainMenu.Model
    }



-- | HeroCreate HeroCreateModel
-- | MapView MapViewModel
-- | RoadView RoadViewModel
-- | CombatView CombatViewModel


init : ( Model, Cmd Msg )
init =
    let
        model =
            Model
                (initContext)
                (initPageModels initContext)
    in
        model ! []


initContext : Context
initContext =
    Context
        Nothing
        []
        Context.MainMenu


initPageModels : Context -> PageModels
initPageModels context =
    PageModels
        (MainMenu.init context)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        context =
            model.context
    in
        case msg of
            ContextMsg msg ->
                case msg of
                    Context.GotoPage page ->
                        let
                            newContext =
                                { context | page = page }
                        in
                            { model | context = newContext } ! []

                    Context.InitPage page ->
                        let
                            newContext =
                                { context | page = page }
                        in
                            { model
                                | context = newContext
                                , pageModels = initPageModel page context model.pageModels
                            }
                                ! []

            MainMenuMsg msg ->
                localUpdate
                    (MainMenu.update msg model.pageModels.mainMenu)
                    MainMenuMsg
                    updateMainMenuPageModel
                    model


localUpdate : ( aModel, Cmd aMsg, Cmd Context.Msg ) -> (aMsg -> Msg) -> (aModel -> PageModels -> PageModels) -> Model -> ( Model, Cmd Msg )
localUpdate ( localModel, localMsg, contextMsg ) msgFunc pageModelsUpdater model =
    let
        pageModels =
            pageModelsUpdater localModel model.pageModels
    in
        { model | pageModels = pageModels }
            ! [ Cmd.map msgFunc localMsg
              , Cmd.map ContextMsg contextMsg
              ]


updateMainMenuPageModel : MainMenu.Model -> PageModels -> PageModels
updateMainMenuPageModel model pageModels =
    { pageModels | mainMenu = model }


initPageModel : Context.Page -> Context -> PageModels -> PageModels
initPageModel page context pageModels =
    case page of
        Context.MainMenu ->
            { pageModels | mainMenu = (MainMenu.init context) }

        Context.HeroCreate ->
            pageModels


view : Model -> Html Msg
view model =
    text "Haro"


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
