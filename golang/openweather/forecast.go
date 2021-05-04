package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
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
	Humidiy    float64
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
	lat, long := 41.1, 2.5
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

	/* Show values in this loop if required
	for _, hourValue := range owData.Hourly {
		fmt.Printf("%v ", time.Unix(hourValue.Dt, 0))
		fmt.Printf("\t%.1f\t%.1f\t%.1f\t%.2f\n", hourValue.Temp, hourValue.Wind_speed, hourValue.Wind_gust, hourValue.Pop)
	}*/

	CheckSeedlings(owData)
	CheckIfWashday(owData)
}

// TODO: Add frost checks too
func CheckSeedlings(owData WeatherData) {
	min_temp := 12.0
	max_wind := 6.0
	fmt.Println("# Putting Seedlings Outside Checks")
	IsCovered := false
	if IsWarmEnough(owData, min_temp, IsCovered) {
		if IsCalmEnough(owData, max_wind) {
			fmt.Printf("\tDay time temps are warm enough")
			fmt.Printf(" and Day time winds are fine\n")
			fmt.Println("->\tPut the seeds outside")
		} else {
			fmt.Println("\tDay time winds are too strong")
		}
	} else {
		fmt.Println("\tDay time temps are too cold")
	}
	fmt.Println("# Putting Seedlings Outside Checks")
	if IsRiskOfFrost(owData, 4.2, false) {
		fmt.Println("\tTake your seeds in tonight")
	}
}

func CheckIfWashday(owData WeatherData) {
	fmt.Println("# Doing The Washing Checks")
	day_offset := 0
	if IsAGoodWashingDay(owData, day_offset) {
		fmt.Println("->\tPut the washing on today")
	} else {
		fmt.Println("\tNo washing today")
	}
	day_offset = 1
	if IsAGoodWashingDay(owData, day_offset) {
		fmt.Println("->\tPut the washing on tomorrow")
	} else {
		fmt.Println("\tNo washing tomorrow")
	}
}

// Looks at temperatures between 9 and 5 to see if it's worth putting seeds outside
func IsWarmEnough(wd WeatherData, min_temp float64, covered bool) bool {
	//d := time.Unix(wd.Hourly[0].Dt, 0)
	//_, _, day := d.Date()
	for _, hourValue := range wd.Hourly {
		d := time.Unix(hourValue.Dt, 0)
		if d.Hour() >= 18 {
			break
		}
		if d.Hour() < 8 {
			continue
		}
		if hourValue.Temp < 10.0 {
			return false
		}
	}
	return true
}

// Looks at temperatures overnight
func IsRiskOfFrost(wd WeatherData, max_temp float64, covered bool) bool {
	d := time.Unix(wd.Hourly[0].Dt, 0)
	hourNow := d.Hour()
	nightTime := wd.Hourly[18-hourNow : 24+8-hourNow]

	// TODO: create slices for overnight windows
	// TODO: loop through those slices for sub 4 degrees, or windchill
	for _, hourValue := range nightTime {
		d := time.Unix(hourValue.Dt, 0)
		if hourValue.Temp < max_temp {
			return true
		}
	}
	return false
}

// Checks to see that the wind is not too strong.
func IsCalmEnough(wd WeatherData, max_speed float64) bool {
	for _, hourValue := range wd.Hourly {
		d := time.Unix(hourValue.Dt, 0)
		if d.Hour() >= 18 {
			break
		}
		if d.Hour() < 8 {
			continue
		}
		if hourValue.Wind_speed > max_speed ||
			hourValue.Wind_gust > max_speed {
			return false
		}
	}
	return true
}

// Checks to see that the wind blows and temperatures are OK.
func IsAGoodWashingDay(wd WeatherData, dayOffset int) bool {

	var max_speed, okay_speed, min_speed = 10.0, 6.0, 3.5
	max_temp, okay_temp, min_temp := 15.0, 12.0, 6.0

	day_name := "today"
	if dayOffset > 0 {
		day_name = "tomorrow"
	}
	good_hour_count := 0

	sunrise := wd.Current.Sunrise
	sunset := wd.Current.Sunset
	dsr := time.Unix(sunrise, 0)
	dss := time.Unix(sunset, 0)
	dayValues := wd.Hourly[dayOffset*24 : 23+(dayOffset*24)]
	for _, hourValue := range dayValues {
		dh := time.Unix(hourValue.Dt, 0)
		if dh.Hour() >= dss.Hour() {
			break
		}
		if dh.Hour() < dsr.Hour() {
			continue
		}
		if hourValue.Pop > 0.05 {
			fmt.Printf("Chance of rain %s at %d:00\n", day_name, dh.Hour())
			good_hour_count = 0
		}
		// Test for cool windy day
		if hourValue.Temp < min_temp &&
			hourValue.Wind_speed < max_speed &&
			hourValue.Wind_gust < max_speed {
			continue
		}
		if hourValue.Temp < okay_temp &&
			hourValue.Wind_speed < okay_speed &&
			hourValue.Wind_gust < (okay_speed+1.0) {
			continue
		}
		// Test for warm gentle day
		if hourValue.Temp < max_temp &&
			hourValue.Wind_speed < min_speed &&
			hourValue.Wind_gust < (min_speed+2.0) {
			continue
		}
		good_hour_count++
	}
	return good_hour_count >= 3
}
