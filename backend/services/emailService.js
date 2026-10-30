const nodemailer = require('nodemailer');

const sendAppRatingEmail = async ({ name, email, rating, feedback, createdAt }) => {
  const ownerEmail = process.env.OWNER_EMAIL || 'raymaanstailors@gmail.com';
  const smtpHost = process.env.SMTP_HOST || 'smtp.gmail.com';
  const smtpPort = process.env.SMTP_PORT ? Number(process.env.SMTP_PORT) : 587;
  const smtpUser = process.env.SMTP_USER;
  const smtpPass = process.env.SMTP_PASS;

  const stars = '★'.repeat(rating) + '☆'.repeat(5 - rating);
  const formattedDate = new Date(createdAt || Date.now()).toLocaleString('en-IN', {
    dateStyle: 'full',
    timeStyle: 'short'
  });

  const htmlContent = `
    <div style="background-color: #000000; padding: 30px; font-family: Arial, sans-serif; color: #FFFFFF;">
      <div style="max-width: 600px; margin: 0 auto; background-color: #111111; border: 1px solid #D4AF37; border-radius: 12px; overflow: hidden;">
        <div style="background-color: #1A1A1A; padding: 20px; text-align: center; border-bottom: 2px solid #D4AF37;">
          <h1 style="color: #D4AF37; margin: 0; font-size: 24px; letter-spacing: 1px;">RT – RAYMAANS TAILORS</h1>
          <p style="color: #CCCCCC; margin: 5px 0 0 0; font-size: 14px;">App Rating & Customer Feedback</p>
        </div>

        <div style="padding: 25px;">
          <div style="text-align: center; margin-bottom: 20px;">
            <div style="font-size: 32px; color: #D4AF37; letter-spacing: 4px; margin-bottom: 8px;">${stars}</div>
            <div style="background-color: #D4AF37; color: #000000; display: inline-block; padding: 4px 12px; border-radius: 20px; font-weight: bold; font-size: 14px;">
              ${rating} out of 5 Stars
            </div>
          </div>

          <table style="width: 100%; border-collapse: collapse; margin-bottom: 20px;">
            <tr>
              <td style="padding: 10px; border-bottom: 1px solid #222222; color: #888888; width: 120px;">Customer Name:</td>
              <td style="padding: 10px; border-bottom: 1px solid #222222; color: #FFFFFF; font-weight: bold;">${name}</td>
            </tr>
            <tr>
              <td style="padding: 10px; border-bottom: 1px solid #222222; color: #888888;">Email Address:</td>
              <td style="padding: 10px; border-bottom: 1px solid #222222; color: #D4AF37;">${email || 'N/A'}</td>
            </tr>
            <tr>
              <td style="padding: 10px; border-bottom: 1px solid #222222; color: #888888;">Submitted On:</td>
              <td style="padding: 10px; border-bottom: 1px solid #222222; color: #FFFFFF;">${formattedDate}</td>
            </tr>
          </table>

          <div style="background-color: #1A1A1A; border-left: 4px solid #D4AF37; padding: 15px; border-radius: 4px;">
            <h3 style="color: #D4AF37; margin: 0 0 10px 0; font-size: 15px;">Customer Feedback:</h3>
            <p style="color: #DDDDDD; margin: 0; line-height: 1.6; font-size: 14px; white-space: pre-wrap;">${feedback}</p>
          </div>
        </div>

        <div style="background-color: #0A0A0A; padding: 15px; text-align: center; border-top: 1px solid #222222; font-size: 12px; color: #777777;">
          Automated notification sent to ${ownerEmail} from RT – Raymaans Tailors App.
        </div>
      </div>
    </div>
  `;

  if (smtpUser && smtpPass) {
    try {
      const transporter = nodemailer.createTransport({
        host: smtpHost,
        port: smtpPort,
        secure: smtpPort === 465, // true for 465, false for 587
        auth: {
          user: smtpUser,
          pass: smtpPass
        }
      });

      const mailOptions = {
        from: `"Raymaans Tailors App" <${smtpUser}>`,
        to: ownerEmail,
        subject: `[App Rating] ${rating}★ Review from ${name}`,
        html: htmlContent
      };

      const info = await transporter.sendMail(mailOptions);
      console.log('✅ Rating Email Delivered via Nodemailer:', info.messageId);
      return true;
    } catch (err) {
      console.error('⚠️ Nodemailer SMTP Error:', err.message);
      return false;
    }
  } else {
    console.log(`ℹ️ SMTP Not Configured. Email payload prepared for owner: ${ownerEmail}`);
    console.log(`Subject: [App Rating] ${rating}★ Review from ${name}`);
    return true;
  }
};

module.exports = {
  sendAppRatingEmail
};
