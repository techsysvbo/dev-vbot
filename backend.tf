terraform {
  cloud {

    organization = "VBO"

    workspaces {
      name = "vbo"
    }
  }
}