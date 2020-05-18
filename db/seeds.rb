# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.admin.
  create(username: "admin", email: "admin@example.com", password: "abcd1234", password_confirmation: "abcd1234").
  confirm
User.moderator.
  create(username: "moderator", email: "mod@example.com", password: "abcd1234", password_confirmation: "abcd1234").
  confirm
User.member.
  create(username: "member", email: "member@example.com", password: "abcd1234", password_confirmation: "abcd1234").
  confirm

Tag.topic.create(id: "algebra", description: "submissions related to algebra")
Tag.media.create(id: "pdf", description: "submission involves a PDF file")
Tag.source.create(id: "research-article", description: "submissions source is a research article")
Tag.meta.create(id: "bug", description: "submission is pointing out a bug on our site")
Tag.mod.create(id: "announcement", description: "submission is an announcement by mod team")
