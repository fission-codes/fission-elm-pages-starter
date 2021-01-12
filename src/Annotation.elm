module Annotation exposing
    ( Annotation
    , encode
    , encodeTitle
    , fromValue
    , notEditing
    , view
    )

import Element exposing (Element)
import Element.Border as Border
import Element.Font as Font
import Element.Input
import Json.Decode exposing (Decoder)
import Json.Encode exposing (Value)
import Pages
import Pages.ImagePath as ImagePath


type Annotation
    = Editable Internals
    | NotEditing


type alias Internals =
    { title : String
    , notes : String
    }



-- CREATE


notEditing : Annotation
notEditing =
    NotEditing


fromValue : Value -> Annotation
fromValue val =
    case Json.Decode.decodeValue internalsDecoder val of
        Ok internals ->
            Editable internals

        Err _ ->
            NotEditing



-- DECODE


internalsDecoder : Decoder Internals
internalsDecoder =
    Json.Decode.map2 Internals
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.field "notes" Json.Decode.string)



-- ENCODE


encode : Annotation -> Json.Encode.Value
encode annotation =
    case annotation of
        Editable internals ->
            Json.Encode.object
                [ ( "title", Json.Encode.string internals.title )
                , ( "notes", Json.Encode.string internals.notes )
                ]

        NotEditing ->
            Json.Encode.null


encodeTitle : String -> Json.Encode.Value
encodeTitle title =
    Json.Encode.object
        [ ( "title", Json.Encode.string title ) ]



-- VIEW


view :
    { annotation : Annotation
    , title : String
    , onLoadAnnotation : String -> msg
    , onUpdateAnnotation : Annotation -> msg
    , onSaveAnnotation : Annotation -> msg
    , onCancelAnnotation : msg
    }
    -> Element msg
view options =
    case options.annotation of
        Editable annotation ->
            Element.row
                [ Element.alignBottom
                , Element.alignRight
                , Element.padding 30
                ]
                [ Element.column
                    [ Border.width 2
                    , Border.roundEach { topLeft = 12, topRight = 12, bottomLeft = 12, bottomRight = 0 }
                    , Border.color (Element.rgb 0.5 0.5 0.5)
                    , Element.padding 3
                    ]
                    [ Element.Input.multiline
                        [ Element.height (Element.px 150)
                        , Element.width (Element.px 200)
                        , Font.size 16
                        , Border.width 0
                        , Element.focused
                            [ Border.color (Element.rgb 0.3 0.3 0.3)
                            , Border.shadow
                                { offset = ( 0, 0 )
                                , blur = 0
                                , color = Element.rgb 0.85 0.85 0.85
                                , size = 0
                                }
                            ]
                        ]
                        { onChange =
                            \newText ->
                                options.onUpdateAnnotation
                                    (Editable
                                        { title = options.title, notes = newText }
                                    )
                        , text = annotation.notes
                        , placeholder =
                            Just
                                (Element.Input.placeholder []
                                    (Element.text ("Write some notes on " ++ options.title))
                                )
                        , label = Element.Input.labelHidden ("Notes on " ++ options.title)
                        , spellcheck = False
                        }
                    , Element.row
                        [ Element.width Element.fill
                        , Element.paddingXY 15 8
                        , Element.spacing 18
                        ]
                        [ Element.Input.button
                            [ Element.width Element.fill
                            , Element.padding 2
                            , Border.width 1
                            , Border.rounded 1
                            , Border.color (Element.rgb255 170 170 170)
                            , Element.mouseOver
                                [ Border.color (Element.rgb255 116 56 245)
                                ]
                            , Font.size 16
                            ]
                            { onPress = Just (options.onSaveAnnotation options.annotation)
                            , label = Element.row [ Element.centerX ] [ Element.text "Save" ]
                            }
                        , Element.Input.button
                            [ Element.width Element.fill
                            , Element.padding 2
                            , Border.width 1
                            , Border.rounded 1
                            , Border.color (Element.rgb255 170 170 170)
                            , Element.mouseOver
                                [ Border.color (Element.rgb255 116 56 245)
                                ]
                            , Font.size 16
                            ]
                            { onPress = Just options.onCancelAnnotation
                            , label = Element.row [ Element.centerX ] [ Element.text "Cancel" ]
                            }
                        ]
                    ]
                ]

        NotEditing ->
            Element.row
                [ Element.alignBottom
                , Element.alignRight
                , Element.padding 30
                ]
                [ Element.Input.button []
                    { onPress = Just (options.onLoadAnnotation options.title)
                    , label =
                        Element.row
                            [ Element.padding 8
                            , Border.width 2
                            , Border.rounded 50
                            , Border.color (Element.rgb 0.3 0.3 0.3)
                            ]
                            [ Element.image
                                [ Element.width (Element.px 30)
                                ]
                                { src = ImagePath.toString Pages.images.annotation
                                , description = "Annotate with Fission"
                                }
                            ]
                    }
                ]
