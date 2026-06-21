class Rack::Attack
  # Throttle all requests by IP - 300 requests per 5 minutes (general safety net)
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  # Throttle login attempts by email - 5 attempts per 20 seconds
# Keyed on email rather than IP alone, since some networks rotate
# client IPs between requests (confirmed on this Railway deployment -
# the same test run alternated between two different source IPs,
# which silently defeated an IP-only throttle).
throttle("logins/email", limit: 5, period: 20.seconds) do |req|
  if req.path == "/admin_users/sign_in" && req.post?
    req.params.dig("admin_user", "email").to_s.downcase.presence
  end
end

  # Throttle public QR redirect hits by IP - 60 per minute (allows real scanning, blocks scripted abuse)
  throttle("qr_redirect/ip", limit: 60, period: 1.minute) do |req|
    if req.path.start_with?("/q/") && req.get?
      req.ip
    end
  end

  self.throttled_responder = lambda do |request|
    [429, { "Content-Type" => "text/plain" }, ["Too many requests. Please slow down and try again shortly.\n"]]
  end
end
