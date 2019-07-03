defmodule Random do
  @moduledoc """
  Documentation for Random.
  """

  @doc """
  Given two uniformly distributed random floats [0,1], get a normally
  distributed one.
  """
  def box_muller(u1,u2) do
    :math.sqrt(-2*:math.log(u1))*:math.cos(2*:math.pi()*u2)
  end

  @doc """
  Given a list of N weights, return an index [0,N-1]
  """
  def weighted_choice(w_list,u1) do
    w_sum = w_list |> Enum.sum()
    w_list
    |> Enum.map(fn x -> x/w_sum end)
    |> Enum.reduce_while({0,0}, 
      fn (x , {cumsum,index}) -> if (cumsum + x) > u1, do: {:halt,index}, else: {:cont,{cumsum+x,index+1}} end
    )
  end
  
  defp cartesian_dist_squared(p1,p2) do
    {x1,y1} = p1
    {x2,y2} = p2
    (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)
  end

  defp cartesian_dist(p1,p2) do
    :math.sqrt(cartesian_dist_squared(p1,p2))
  end

  defp polar_dist_squared(p1,p2) do
    {r1,phi1} = p1
    {r2,phi2} = p2
    r1*r1 + r2*r2 - 2*r1*r2*:math.cos(phi2-phi1)
  end

  defp polar_dist(p1,p2) do
    :math.sqrt(polar_dist_squared(p1,p2))
  end
  
  @doc """
  Returns a distance function for points. Valid inputs are
  :cartesian_sq for square of cartesian distance
  :cartesian for cartesian distance
  :polar_sq for square of polar distance
  :polar for polar distance
  """
  def dist_func(sigil) do
    case sigil do
      :cartesian_sq -> &cartesian_dist_squared/2
      :cartesian -> &cartesian_dist/2
      :polar_sq -> &polar_dist_squared/2
      :polar -> &polar_dist/2
    end
  end
  
  def low_density_blue(ncpts,u_list) do
    low_density_blue(ncpts,:cartesian_sq,u_list)
  end

  def low_density_blue(ncpts,stuff,u_list,bounds \\ {1,1})

  def low_density_blue(ncpts,atom,u_list,bounds) when is_atom(atom) do
    low_density_blue(ncpts,dist_func(atom),u_list,bounds)
  end
  
  @doc """
  returns (length(u_list)-2 )/(2*ncpts+1) low density blue points
  for n pts, give n*(2*ncpts+1) + 2 uniform random numbers
  """
  def low_density_blue(ncpts,distfunc,u_list,bounds) when is_function(distfunc) do
    [xi,yi | rest_u_list] = u_list
    u_list_list = Enum.chunk_every(rest_u_list,2*ncpts+1)
    Enum.reduce(u_list_list,[{xi,yi}],fn u_part , acc -> low_density_blue_add_pt(acc,distfunc,bounds,u_part) end)
  end
  
  def ldb_len(npts,ncpts) do
    npts*(2*ncpts+1) + 2
  end

  defp low_density_blue_add_pt(setpts,distfunc,bounds,u_list) do
    {xs,yplus} = Enum.split(u_list,trunc(length(u_list)/2))
    ys = Enum.take(yplus,length(yplus)-1)
    [u1] = Enum.take(yplus,-1)
    {xbound,ybound} = bounds
    candidates = Enum.zip(xs,ys) 
                 |> Enum.map(fn {x,y} -> {x*xbound,y*ybound} end)
    idx = Enum.map(candidates,
      fn cpt -> Enum.sum(Enum.map(setpts,fn spt -> distfunc.(spt,cpt) end)) end )
      |> weighted_choice(u1)
    chosen = Enum.at(candidates,idx)
    setpts ++ [chosen]
  end
end 
