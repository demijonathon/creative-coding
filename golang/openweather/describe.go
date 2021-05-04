package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"
)

type OpenWeatherMap struct {
	API_KEY string
}

type City struct {
	Id   int    `json:"id"`
	Name string `json:"name"`
}

type Coord struct {
	Lon float64 `json:"lon"`
	Lat float64 `json:"lat"`
}

type Weather struct {
	Id          int    `json:"id"`
	Main        string `json:"main"`
	Description string `json:"description"`
	Icon        string `json:"icon"`
}

type Wind struct {
	Speed float64 `json:"speed"`
	Deg   float64 `json:"deg"`
}

type Clouds struct {
	All int `json:"all"`
}

type Rain struct {
	Threehr int `json:"3h"`
}

type Main struct {
	Temp     float64 `json:"temp"`
	Pressure int     `json:"pressure"`
	Humidity int     `json:"humidity"`
	Temp_min float64 `json:"temp_min"`
	Temp_max float64 `json:"temp_max"`
}

/*
Define API response objects (compose of the above fields)
*/

type CurrentWeatherResponse struct {
	Coord   `json:"coord"`
	Sunrise int64     `json:"sunrise"`
	Sunset  int64     `json:"sunset"`
	Weather []Weather `json:"weather"`
	Main    `json:"main"`
	Wind    `json:"wind"`
	Rain    `json:"rain"`
	Clouds  `json:"clouds"`
	Dt      int    `json:"dt"`
	Id      int    `json:"id"`
	Name    string `json:"name"`
}

type HourlyData struct {
	Dt         int64
	Temp       float64
	Feels_like float64 `json:"feels_like"`
	Wind_speed float64 `json:"wind_speed"`
	Wind_gust  float64 `json:"wind_gust"`
	Wind_deg   int     `json:"wind_deg"`
	Humidity   float64
	Dew_point  float64
	Pop        float64
}

type WeatherData struct {
	Lat             float64
	Lon             float64
	Timezone        string
	Timezone_offset int
	Current         CurrentWeatherResponse
	Hourly          []HourlyData
	//daily []DailyData
	//alerts []AlertData
}

func main() {
	lat, err := strconv.ParseFloat(os.Args[1], 32)
	if err != nil {
		fmt.Fprintf(os.Stderr, "First param [%v] is not a float: %v\n", os.Args[1], err)
		os.Exit(1)
	}
	long, err := strconv.ParseFloat(os.Args[2], 32)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Second param [%v] is not a float: %v\n", os.Args[2], err)
		os.Exit(1)
	}

	exclude := "minutely"
	baseurl := "api.openweathermap.org/data/2.5/onecall"
	units := "metric"

	apikey, err := ioutil.ReadFile("./.apikey")
	if err != nil {
		fmt.Fprintf(os.Stderr, "Read file error: %v\n", err)
		os.Exit(1)
	}
	url := strings.TrimSuffix(fmt.Sprintf("http://%s?lat=%.3f&lon=%.3f&exclude=%s&units=%s&appid=%s",
		baseurl, lat, long, exclude, units, apikey), "\n")
	//fmt.Println("URL = ", url)

	resp, err := http.Get(url)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Get URL error: %v\n", err)
		os.Exit(1)
	}

	b, err := ioutil.ReadAll(resp.Body)
	//b, err := ioutil.ReadFile("./response.example.3")
	resp.Body.Close()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Read body error: %v\n", err)
		os.Exit(1)
	}
	var owData WeatherData
	json.Unmarshal([]byte(b), &owData)

	/* Show values in this loop if required */
	fmt.Printf("Describing conditions for lat %.3f, long %.3f - timezone of %s\n", lat, long, owData.Timezone)
	fmt.Printf("%s\t\t\t%s\t%s\t%s\t%s\t%s\n", "Timestamp", "Temp", "Wind", "Dew", "Hum", "Rain")

	for _, hourValue := range owData.Hourly {
		fmt.Printf("%v ", time.Unix(hourValue.Dt, 0))
		fmt.Printf("\t%.1f\t%.1f\t%.1f\t%.1f\t%.2f\n", hourValue.Temp, hourValue.Wind_speed, hourValue.Dew_point, hourValue.Humidity, hourValue.Pop)
	}

}
