FROM archlinux:base

RUN pacman-key --init && pacman -Sy --noconfirm base-devel neovim git wget unzip npm nodejs python ripgrep fd

RUN useradd -ms /bin/bash blyedev
WORKDIR /home/blyedev/

COPY --chown=blyedev:blyedev . ./.config/nvim

USER blyedev
WORKDIR /home/blyedev/

RUN nvim --headless +Lazy! sync +qa

CMD ["nvim"]
