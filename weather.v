module main

import net.http
import os
import json

struct City {
	title         string
	location_type string
	woeid         int
	latt_long     string
}

struct WeatherResponse {
	consolidated_weather []WeatherSource
}

struct WeatherSource {
	the_temp f64
}

fn main() {
	if os.args.len < 2 {
		println('specify city (e.g. weather.exe Moscow)')
		return
	}
	city := os.args[1]
	println('searching $city')
	woeid := get_city(city) or {
		println(err)
		return
	}
	$if debug {
		println('city woeid: $woeid')
	}
	weather_json := get_weather(woeid) or {
		println(err)
		return
	}
	temp := weather_json.consolidated_weather[0].the_temp
	println('current temperature in $city: $temp')
}

fn get_weather(woeid int) ?WeatherResponse {
	weather_res := http.get_text('https://www.metaweather.com/api/location/$woeid/')
	weather_json := json.decode(WeatherResponse, weather_res) or {
		$if debug {
			println(err)
		}
		return error('failed to fetch data')
	}
	return weather_json
}

fn get_city(city string) ?int {
	city_res := http.get_text('https://www.metaweather.com/api/location/search/?query=$city')
	cities := json.decode([]City, city_res) or {
		return error('failed to fetch city')
	}
	$if debug {
		println(cities)
	}
	if cities.len == 0 {
		return error('unknown city')
	}
	return cities[0].woeid
}
