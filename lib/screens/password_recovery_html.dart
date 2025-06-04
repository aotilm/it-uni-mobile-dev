class PasswordRecoveryHtml {
  static String html(int recoveryCode) {
    return '''
  <!DOCTYPE html>
<html lang="uk">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Лист відновлення</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f7f7f7;
      margin: 0;
      padding: 0;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
    }
    .container {
      background-color: #ffffff;
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
      max-width: 600px;
      text-align: center;
    }
    h2 {
      color: #4CAF50;
      margin-bottom: 20px;
    }
    p {
      color: #333333;
      line-height: 1.5;
    }
    .footer {
      margin-top: 20px;
      font-size: 0.9em;
      color: #777777;
    }
  </style>
</head>
<body>
  <div class="container">
    <p>Вітаємо!</p>
    <p>Ваш код для відновлення пароля:</p>
    <h2>$recoveryCode</h2>
    <p>Будь ласка, використовуйте цей код для відновлення вашого облікового запису.</p>
    <p>Якщо ви не запитували відновлення пароля, проігноруйте цей лист.</p>
    <div class="footer">
      <p>З найкращими побажаннями<brIllia Muravets</p>
    </div>
  </div>
</body>
</html>
  ''';
  }
}