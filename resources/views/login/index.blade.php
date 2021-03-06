<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Inicio - SeatOrganizer 0.1</title>
	<!--Style Sheets-->
	<link href='https://fonts.googleapis.com/css?family=Raleway:300,200' rel='stylesheet' type='text/css'>
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/meyer-reset/2.0/reset.min.css">
	<link rel="stylesheet" href="../css/style.css">
	<!--Scripts-->
	<script src='http://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.3/jquery.min.js'></script>
	<script  src="../js/index.js"></script>
</head>
<body>
  <form action="{{ route('login') }}" method="post">
  	<div class="form">
  		<div class="forceColor"></div>
  		<div class="topbar">
  			<div class="spanColor"></div>
  			<input type="text" class="input" id="user" placeholder="Usuario"/>
  			<input type="password" class="input" id="password" placeholder="Contraseña"/>
  		</div>
  		<button class="submit" id="submit" onclick="nextView()">Ingresar</button>
  	</div>
  </form>
</body>
</html>
