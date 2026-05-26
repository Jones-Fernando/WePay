import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from database.config import Config


class EmailService:
    @staticmethod
    def _enviar_email(email_destino: str, assunto: str, corpo_texto: str, corpo_html: str = None) -> bool:
        if not Config.EMAIL_REMETENTE or not Config.EMAIL_SENHA_APP:
            print(f"[EMAIL] Credenciais nao configuradas. Destino: {email_destino}")
            return False

        try:
            msg = MIMEMultipart('alternative')
            msg['Subject'] = assunto
            msg['From'] = f'WePay <{Config.EMAIL_REMETENTE}>'
            msg['To'] = email_destino

            msg.attach(MIMEText(corpo_texto, 'plain', 'utf-8'))
            if corpo_html:
                msg.attach(MIMEText(corpo_html, 'html', 'utf-8'))

            if Config.EMAIL_PORT == 465:
                servidor = smtplib.SMTP_SSL(Config.EMAIL_SERVER, Config.EMAIL_PORT)
            else:
                servidor = smtplib.SMTP(Config.EMAIL_SERVER, Config.EMAIL_PORT)
                servidor.ehlo()
                servidor.starttls()
                servidor.ehlo()

            with servidor as servidor:
                servidor.login(Config.EMAIL_REMETENTE, Config.EMAIL_SENHA_APP)
                servidor.sendmail(Config.EMAIL_REMETENTE, email_destino, msg.as_string())

            print(f"[EMAIL] Email enviado com sucesso para {email_destino}")
            return True

        except smtplib.SMTPAuthenticationError as e:
            print(f"[EMAIL] Erro de autenticacao. Verifique EMAIL_REMETENTE e EMAIL_SENHA_APP no .env. Detalhe: {e}")
            return False
        except smtplib.SMTPException as e:
            print(f"[EMAIL] Erro SMTP: {type(e).__name__}: {e}")
            return False
        except Exception as e:
            print(f"[EMAIL] Erro inesperado ao enviar email: {type(e).__name__}: {e}")
            return False

    @staticmethod
    def enviar_recuperacao_senha(email_destino: str, nova_senha: str) -> bool:
        corpo_texto = (
            f"Olá!\n\n"
            f"Recebemos uma solicitação de recuperação de senha para sua conta WePay.\n\n"
            f"Sua nova senha temporária é: {nova_senha}\n\n"
            f"Recomendamos que você altere essa senha após o login.\n\n"
            f"Se você não solicitou isso, ignore este e-mail.\n\n"
            f"Equipe WePay"
        )

        corpo_html = f"""
        <html>
          <body style="font-family: Arial, sans-serif; background-color: #f8f9fa; padding: 20px;">
            <div style="max-width: 480px; margin: auto; background: white; border-radius: 8px; padding: 32px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
              <h2 style="color: #009688; text-align: center;">🔐 WePay</h2>
              <h3 style="color: #333;">Recuperação de Senha</h3>
              <p style="color: #555;">Recebemos uma solicitação de recuperação de senha para sua conta.</p>
              <p style="color: #555;">Sua nova senha temporária é:</p>
              <div style="background: #e0f2f1; border-radius: 6px; padding: 16px; text-align: center; margin: 16px 0;">
                <span style="font-size: 24px; font-weight: bold; color: #009688; letter-spacing: 4px;">{nova_senha}</span>
              </div>
              <p style="color: #888; font-size: 13px;">Recomendamos que você altere essa senha após o login.</p>
              <p style="color: #bbb; font-size: 12px;">Se você não solicitou isso, ignore este e-mail.</p>
              <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
              <p style="color: #bbb; font-size: 11px; text-align: center;">Equipe WePay</p>
            </div>
          </body>
        </html>
        """

        return EmailService._enviar_email(email_destino, 'WePay - Recuperação de Senha', corpo_texto, corpo_html)

    @staticmethod
    def enviar_email_teste(email_destino: str) -> bool:
        corpo_texto = (
            f"Olá!\n\n"
            f"Este é um email de teste enviado pelo servidor WePay para verificar suas configurações de SMTP.\n\n"
            f"Se você recebeu este e-mail, a configuração está funcionando.\n\n"
            f"Equipe WePay"
        )

        corpo_html = f"""
        <html>
          <body style="font-family: Arial, sans-serif; background-color: #f8f9fa; padding: 20px;">
            <div style="max-width: 480px; margin: auto; background: white; border-radius: 8px; padding: 32px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
              <h2 style="color: #009688; text-align: center;">🔧 WePay</h2>
              <h3 style="color: #333;">Teste de Envio de Email</h3>
              <p style="color: #555;">Este é um email de teste enviado pelo servidor WePay para verificar a configuração de SMTP.</p>
              <p style="color: #555;">Se você receber esta mensagem, o envio está funcionando corretamente.</p>
              <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
              <p style="color: #bbb; font-size: 11px; text-align: center;">Equipe WePay</p>
            </div>
          </body>
        </html>
        """

        return EmailService._enviar_email(email_destino, 'WePay - Teste de Email', corpo_texto, corpo_html)
