<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Http\Seat;
use App\Http\Section;
use App\Http\Area;
use Session;
use DB;

class SeatApi extends Controller
{
    public function index()
    {
        $seats = Seat::all();
        $list = array();

        if(count($seats) == 0) {
            $array = array('status' => 1, 'message' => 'Seats not found');
            return response()->json($array);
        }

        foreach ($seats as $seat) {
            $section = Section::find($seat->section);
            $area = Area::find($section->area);

            $arrayArea = [
                'id' => $area->id,
                'name' => $area->name
            ];

            $arraySection = [
                'id' => $section->id,
                'area' => $arrayArea,
                'name' => $section->name,
                'color' => $section->color
            ];

            $arraySeat = [
                'id' => $seat->id,
                'row' => $seat->row,
                'column' => $seat->column,
                'section' => $arraySection
            ];
            array_push($list, $arraySeat);
        }

        $array = array('status' => 0, 'seats' => $list);
        return response()->json($array);
    }

    public function show($id)
    {
        $seat = DB::table('seats')
                    ->join('sections', 'seats.section', '=', 'sections.id')
                    ->join('areas', 'sections.area', '=', 'areas.id')
                    ->select('seats.id as seatsId', 'seats.row as seatsRow', 'seats.column as seatsColumn', 'seats.section as seatsSection', 'seats.status as seatsStatus',
                        'sections.id as sectionsId', 'sections.area as sectionsArea', 'sections.name as sectionsName', 'sections.color as sectionsColor',
                        'areas.id as areasId', 'areas.name as areasName'
                    )
                    ->where('seats.id', $id)
                    ->get();

        try {
            $area = [
                'id' => $seat[0]->areasId,
                'name' => $seat[0]->areasName
            ];

            $section = [
                'id' => $seat[0]->sectionsId,
                'area' => $area,
                'name' => $seat[0]->sectionsName,
                'color' => $seat[0]->sectionsColor
            ];

            $seat = [
                'id' => $seat[0]->seatsId,
                'row' => $seat[0]->seatsRow,
                'column' => $seat[0]->seatsColumn,
                'section' => $section
            ];

            $array = array('status' => 0, 'seat' => $seat);
            return response()->json($array);
        } catch(\Exception $e) {
              $array = array(
                  'status' => 1,
                  'message' => 'Seat not found'
              );
              return response()->json($array);
        }

    }

    public function section($section) {
        try {
            $seats = DB::table('seats')
                        ->select('id', 'row', 'column', 'section', 'status')
                        ->where('section', $section)
                        ->get();

            $array = array('status' => 0, 'seats' => $seats);
            return response()->json($array);
        } catch(\Exception $e) {
            $array = array(
                'status' => 1,
                'message' => 'Seat not found'
            );
            return response()->json($array);
        }
    }

    public function getList()
    {
        try {
            if (Session::exists('seats')) {
                $session = session('seats');
                $array = array('Seleccionados' => $session);
                return response()->json($array);
            } else {
                $array = array('status' => 1, 'errorMessage' => 'Lista vacia.');
                return response()->json($array);
            }


        } catch(\Exception $e) {
            $array = array('status' => 1, 'message' => $e->getMessage());
            return response()->json($array);
        }
    }

    public function addList($id, $price)
    {
        $array = collect([
          'id' => $id,
          'price' => $price
        ]);

        try {
            if (Session::exists('seats')) {
                Session::push('seats', $array);
            } else {
                Session::put('seats', $array);
            }

            $array = array('status' => 0, 'message' => 'Ok');
            return session('seats');
        } catch(\Exception $e) {
            $array = array('status' => 1, 'message' => $e->getMessage());
            return response()->json($array);
        }
    }

    public function addList2($id, $price)
    {
        session_id("lista");
        session_start();

        try {
            $array = collect(['id' => $id, 'price' => $price]);
            // Creates or recover the node list
            if (!isset($_SESSION['lista'])) {
                $_SESSION['lista'] = array();
            }
            array_push($_SESSION['lista'], $array);

            echo json_encode(array(
              'status' => 0,
              'message' => $id.' con $'.$price.' se ha insertado satisfactoriamente.'
            ));
        } catch (\Excepction $ex) {
            echo json_encode(array(
              'status' => 1,
              'errorMessage' => 'Something was wrong.'
            ));
        }
        session_write_close();
    }

    public function getList2()
    {
      session_id("lista");
      session_start();

        try {
          // Creates or recover the node list
            if (@$_SESSION['lista']) {
                $b = $_SESSION['lista'];
                return response()->json($b);
            } else {
                echo json_encode(array(
                  'status' => 1,
                  'errorMessage' => 'The list is empty.'
                ));
            }
        } catch (\Excepction $ex) {
            echo json_encode(array(
              'status' => 2,
              'errorMessage' => 'Something was wrong.'
            ));
        }
        session_write_close();
    }

    public function getSeatArea($section, $area)
    {
        $seats = DB::table('seats')
                    ->join('sections', 'seats.section', '=', 'sections.id')
                    ->join('areas', 'sections.area', '=', 'areas.id')
                    ->select('seats.id as seatsId', 'seats.row as seatsRow', 'seats.column as seatsColumn', 'seats.section as seatsSection', 'seats.status as seatsStatus',
                        'sections.id as sectionsId', 'sections.area as sectionsArea', 'sections.name as sectionsName', 'sections.color as sectionsColor',
                        'areas.id as areasId', 'areas.name as areasName'
                    )
                    ->where([
                      ['seats.section', $section],
                      ['sections.area', $area]
                    ])->get();
                    //->groupBy('events.name', 'sections.name', 'prices.price')
        $list = array();

        foreach ($seats as $seat) {
            $area = array(
                'id' => $seat->areasId,
                'name' => $seat->areasName
            );

            $section = array(
                'id' => $seat->sectionsId,
                'area' => $area,
                'name' => $seat->sectionsName,
                'color' => $seat->sectionsColor
            );

            $seat = array(
                'id' => $seat->seatsId,
                'row' => $seat->seatsRow,
                'column' => $seat->seatsColumn,
                'section' => $section,
                'status' => $seat->seatsStatus,
            );

            array_push($list, $seat);
        }

        $array = array('status' => 0, 'seats' => $list);
        return response()->json($array);

    }
}
