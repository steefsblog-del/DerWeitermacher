<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RSA 21 Baustellenmanagement - Startseite</title>
    <link rel="stylesheet" href="/css/style.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            max-width: 1200px;
            width: 100%;
            padding: 20px;
        }
        .login-section {
            display: flex;
            gap: 40px;
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        }
        .login-form, .info-section {
            flex: 1;
            padding: 50px;
        }
        .info-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .info-section h2 {
            margin-bottom: 20px;
            font-size: 28px;
        }
        .info-section ul {
            list-style: none;
        }
        .info-section li {
            margin-bottom: 15px;
            padding-left: 30px;
            position: relative;
        }
        .info-section li:before {
            content: "✓";
            position: absolute;
            left: 0;
            font-weight: bold;
            font-size: 18px;
        }
        .login-form h1 {
            margin-bottom: 30px;
            color: #333;
            font-size: 24px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: 600;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        .form-group input:focus, .form-group select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        .btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        .tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            border-bottom: 2px solid #ddd;
        }
        .tab {
            padding: 10px 20px;
            cursor: pointer;
            border: none;
            background: none;
            font-size: 16px;
            color: #999;
            border-bottom: 3px solid transparent;
            transition: all 0.3s;
        }
        .tab.active {
            color: #667eea;
            border-bottom-color: #667eea;
        }
        .tab-content {
            display: none;
        }
        .tab-content.active {
            display: block;
        }
        .error {
            color: #dc3545;
            margin-bottom: 15px;
            padding: 10px;
            background-color: #f8d7da;
            border-radius: 5px;
        }
        .success {
            color: #155724;
            margin-bottom: 15px;
            padding: 10px;
            background-color: #d4edda;
            border-radius: 5px;
        }
        @media (max-width: 768px) {
            .login-section {
                flex-direction: column;
                gap: 0;
            }
            .login-form, .info-section {
                padding: 30px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="login-section">
            <div class="info-section">
                <h2>RSA 21 Baustellenmanagement</h2>
                <p style="margin-bottom: 30px; font-size: 14px; opacity: 0.9;">Professionelle Verwaltung von Baustellen-Verkehrszeichen</p>
                <ul>
                    <li>Drag-and-Drop Baukasten</li>
                    <li>Vorgefertigte Templates</li>
                    <li>Automatische PDF-Generierung</li>
                    <li>RSA 21 Validierung</li>
                    <li>Projektverwaltung</li>
                    <li>Dokumentation & Protokolle</li>
                </ul>
            </div>
            <div class="login-form">
                <div class="tabs">
                    <button class="tab active" onclick="switchTab('login')">Anmelden</button>
                    <button class="tab" onclick="switchTab('register')">Registrieren</button>
                </div>

                <!-- Login Tab -->
                <div id="login" class="tab-content active">
                    <h1>Anmelden</h1>
                    <form id="loginForm">
                        <div class="form-group">
                            <label for="loginEmail">E-Mail</label>
                            <input type="email" id="loginEmail" name="email" required>
                        </div>
                        <div class="form-group">
                            <label for="loginPassword">Passwort</label>
                            <input type="password" id="loginPassword" name="password" required>
                        </div>
                        <button type="submit" class="btn">Anmelden</button>
                    </form>
                </div>

                <!-- Register Tab -->
                <div id="register" class="tab-content">
                    <h1>Registrieren</h1>
                    <form id="registerForm">
                        <div class="form-group">
                            <label for="regFirstname">Vorname</label>
                            <input type="text" id="regFirstname" name="firstname" required>
                        </div>
                        <div class="form-group">
                            <label for="regLastname">Nachname</label>
                            <input type="text" id="regLastname" name="lastname" required>
                        </div>
                        <div class="form-group">
                            <label for="regUsername">Benutzername</label>
                            <input type="text" id="regUsername" name="username" required>
                        </div>
                        <div class="form-group">
                            <label for="regEmail">E-Mail</label>
                            <input type="email" id="regEmail" name="email" required>
                        </div>
                        <div class="form-group">
                            <label for="regCompany">Unternehmen (optional)</label>
                            <input type="text" id="regCompany" name="company">
                        </div>
                        <div class="form-group">
                            <label for="regPassword">Passwort</label>
                            <input type="password" id="regPassword" name="password" required>
                        </div>
                        <div class="form-group">
                            <label for="regPassword2">Passwort wiederholen</label>
                            <input type="password" id="regPassword2" name="password2" required>
                        </div>
                        <button type="submit" class="btn">Registrieren</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        function switchTab(tab) {
            document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.tab').forEach(el => el.classList.remove('active'));
            document.getElementById(tab).classList.add('active');
            event.target.classList.add('active');
        }

        document.getElementById('loginForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            const email = document.getElementById('loginEmail').value;
            const password = document.getElementById('loginPassword').value;

            try {
                const response = await fetch('/src/api/auth.php?action=login', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ email, password })
                });
                const data = await response.json();
                if (data.success) {
                    window.location.href = '/public/dashboard.php';
                } else {
                    alert('Anmeldung fehlgeschlagen: ' + data.error);
                }
            } catch (error) {
                alert('Fehler: ' + error.message);
            }
        });

        document.getElementById('registerForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            const data = {
                username: document.getElementById('regUsername').value,
                email: document.getElementById('regEmail').value,
                firstname: document.getElementById('regFirstname').value,
                lastname: document.getElementById('regLastname').value,
                company: document.getElementById('regCompany').value,
                password: document.getElementById('regPassword').value
            };

            if (data.password !== document.getElementById('regPassword2').value) {
                alert('Passwörter stimmen nicht überein');
                return;
            }

            try {
                const response = await fetch('/src/api/auth.php?action=register', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(data)
                });
                const result = await response.json();
                if (result.success) {
                    alert('Registrierung erfolgreich! Sie können sich jetzt anmelden.');
                    switchTab('login');
                } else {
                    alert('Registrierung fehlgeschlagen: ' + result.error);
                }
            } catch (error) {
                alert('Fehler: ' + error.message);
            }
        });
    </script>
</body>
</html>
