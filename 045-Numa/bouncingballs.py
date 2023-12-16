import random
import math
import pygame

screen = None  # JCN
balls = []
screen_width = 0
screen_height = 0
antal = 0

class Ball:
    def __init__(self, x, y, radius, dx, dy, colors):
        self.x = x
        self.y = y
        self.radius = radius
        self.dx = dx
        self.dy = dy
        self.colors = colors
        self.antal = 0 # JCN

    def draw(self):
        self.antal += 1
        pygame.draw.circle(screen, self.colors[self.antal % len(self.colors)], (self.x, self.y), self.radius)

    def update_position(self):
        self.x += self.dx
        self.y += self.dy

    def update_speed(self):
        global screen_width, screen_height
        if self.x - self.radius < 0 or screen_width < self.x + self.radius:
            self.dx = -self.dx
        if screen_height < self.y + self.radius:
            self.dy = -self.dy
        else:
            self.dy += 1

def main():
    global screen # JCN
    global screen_width, screen_height, antal
    pygame.init()
    screen_width = pygame.display.Info().current_w - 50
    screen_height = pygame.display.Info().current_h - 50
    screen = pygame.display.set_mode((screen_width, screen_height))
    pygame.display.set_caption("Bouncing Ball")
    clock = pygame.time.Clock()
    screen.fill((192, 192, 192))  # gray background

    running = True
    while running:

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.MOUSEBUTTONDOWN:
                antal += 1
                for _ in range(100):
                    x = pygame.mouse.get_pos()[0]
                    y = pygame.mouse.get_pos()[1]
                    dy = random.choice([4, 5, 7, 8, 9, 10])
                    colors = ['red', 'blue', 'green', 'yellow', 'white', 'orange', 'Chartreuse']
                    balls.append(Ball(x, y, 42, 5, dy, random.sample(colors, random.choice([2, 3]))))

        text_font = pygame.font.Font(None, 50)
        text_surface = text_font.render(str(antal), True, (0, 0, 0))
        screen.blit(text_surface, (100, 100))

        for ball in balls:
            ball.draw()
            ball.update_position()
            ball.update_speed()

        pygame.display.flip()
        clock.tick(60)

    pygame.quit()

if __name__ == "__main__":
    main()
