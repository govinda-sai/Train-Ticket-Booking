Train detials booking system (Model)
	- train id
	- train	name
	- train number 
	- no. of seats 
	- beginning station 
	- destination station 
	- stops 
	- price for each stop
	- start time
	- end time 
- CRUD Operations
- APIs that enables the user to search a train by name, number, beginning station, destination station, start time, end time
	
	
Booking details (Model)
	- booking id
	- pnr number (13 digits) 
		- should starts with "PNR"<10 digits>
		- should be unique 
	- no. of seats
	- Passenger details (Model) - id
				    - name
				    - age 
				    - gender 
				    - email
				    - phone number
	- from station
	- destination station
	- train name
	- train number 
	- date of booking
	- status 
	
- CRUD Operations
- API to change the schedule
- API to list all the booked train tickets
- Option to cancel a ticket


<!-- [1, 2, 3, 4, 5].each { |n| PassengerDetail.create(name: "Passenger #{n}", age: rand(18..50), gender: ["Male", "Female"].sample, email: "passenger#{n}@example.com", phone: "123456789#{n}") } -->
