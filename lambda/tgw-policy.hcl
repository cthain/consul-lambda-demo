service "lambda-payments" {
  policy = "write"
  intentions = "read"
}

service "payments" {
  policy = "write"
  intentions = "read"
}
