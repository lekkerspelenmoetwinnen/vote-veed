Veed.add_file "index.html", %{<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta http-equiv="x-ua-compatible" content="ie=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1, user-scalable=0">
	<title>Veed stemmen</title>
	<link href="https://fonts.googleapis.com/css?family=Montserrat:100,200,300,400,500,600,700,800,900" rel="stylesheet">
	<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.5.0/css/all.css" integrity="sha384-B4dIYHKNBt8Bc12p+WXckhzcICo0wtJAoU8YZTY5qE0Id1GSseTk6S+L3BlXeVIU" crossorigin="anonymous">
	<link media="all" rel="stylesheet" href="/css/style.css">
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js" defer></script>
	<script>window.jQuery || document.write('<script src="/js/jquery-3.3.1.min.js" defer><\/script>')</script>
	<script src="/js/jquery.main.js" defer></script>
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-59215967-4"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-59215967-4');
</script>

</head>
<body>
<div id="messages"></div><div id="warnings"></div><div id="errors"></div>
	<div id="wrapper">
		<div class="wrapper-holder">
<div class="container">
				<form method="post" class="form-area">
<input type="hidden" name="action" value="voter">
					<h1>Hoi!<span class="heading">laat ons hier weten wie je bent</span></h1>
					<div class="field-holder">
						<div class="wrap">
							<label class="" for="name">Naam</label>
							<input class="" type="text" name="name" id="name" placeholder="" value="">
						</div>
					</div>
					<div class="field-holder">
						<div class="wrap">
							<label class="" for="email">Email</label>
							<input class="" type="email" name="email" id="email" placeholder="" value="">
						</div>
					</div>
					<div class="field-holder">
						<div class="wrap">
							<label class="" for="phone">Telefoon</label>
							<input class="" type="text" name="phone" id="phone" placeholder="" value="">
							<span class="optional-text">optioneel</span>
						</div>
						<div class="help-text">
							<span class="help">Voer in en maak kans op 2 kaarten</span>
						</div>
					</div>
					<div class="field-holder">
						<div class="wrap">
							<label class="" for="birthdate">Geboortedatum</label>
							<input class="" type="text" name="birthdate" id="birthdate" placeholder="" value="">
							<a href="#" class="help-icon">i</a>
						</div>
					</div>
					<div class="field-holder">
						<div class="wrap">
							<input class="" type="checkbox" name="parent_permission" id="parent_permission" value="1" %parent_permission_checked%>
							<label class=" checkbox" for="parent_permission">Toestemming van ouder
								<span class="checkbox-icon"><i class="fas fa-check"></i></span>
							</label>
						</div>
					</div>
					<div class="field-holder">
						<div class="wrap">
							<input class="" type="checkbox" name="terms_agreed" id="terms_agreed" value="1" %terms_agreed_checked%>
							<label class=" checkbox" for="terms_agreed">Akkoord met voorwaarden
								<span class="checkbox-icon"><i class="fas fa-check"></i></span>
							</label>
						</div>
					</div>
					<input type="submit" value="Begin met stemmen">
				</form>
			</div>
</div>
</div>
</body>
</html>}
